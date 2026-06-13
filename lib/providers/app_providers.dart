import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user_profile.dart';
import '../data/models/token_balance.dart';
import '../data/models/transaction_model.dart';
import '../data/models/daily_task.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    final isDark = Hive.box('settings').get('isDark');
    if (isDark != null) state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Hive.box('settings').put('isDark', state == ThemeMode.dark);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) => ProfileNotifier());

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final _box = Hive.box<UserProfile>('profile');
  
  ProfileNotifier() : super(null) {
    state = _box.get('main');
  }

  void createWallet() {
    final profile = UserProfile(
      id: const Uuid().v4(),
      inviteCode: 'ECO-${const Uuid().v4().substring(0,6).toUpperCase()}',
      streak: 0,
      level: 1,
      joinDate: DateTime.now(),
    );
    _box.put('main', profile);
    state = profile;
    
    final balanceBox = Hive.box<TokenBalance>('balance');
    balanceBox.put('main', const TokenBalance(total: 0, allTimeMined: 0));
  }

  void completeTreeTask() {
    if (state == null) return;
    final updated = state!.copyWith(hasPlantedTreeToday: true);
    _box.put('main', updated);
    state = updated;
  }
  
  void updateLevelAndStreak(int newStreak, int newLevel, DateTime mineTime) {
    if (state == null) return;
    final updated = state!.copyWith(
      streak: newStreak, 
      level: newLevel, 
      lastMineTime: mineTime,
      hasPlantedTreeToday: false,
    );
    _box.put('main', updated);
    state = updated;
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, TokenBalance>((ref) => BalanceNotifier());

class BalanceNotifier extends StateNotifier<TokenBalance> {
  final _box = Hive.box<TokenBalance>('balance');
  
  BalanceNotifier() : super(const TokenBalance(total: 0, allTimeMined: 0)) {
    state = _box.get('main') ?? const TokenBalance(total: 0, allTimeMined: 0);
  }

  void addTokensSilent(double amount) {
    final updated = state.copyWith(
      total: state.total + amount,
      allTimeMined: state.allTimeMined + amount,
    );
    _box.put('main', updated);
    state = updated;
  }

  void addTransaction(String type, double amount, String desc) {
    final txBox = Hive.box<TransactionModel>('transactions');
    txBox.add(TransactionModel(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      timestamp: DateTime.now(),
      description: desc,
    ));
  }

  void addTokens(double amount, String type, String desc) {
    addTokensSilent(amount);
    addTransaction(type, amount, desc);
  }
}

final miningProvider = StateNotifierProvider<MiningNotifier, MiningState>((ref) => MiningNotifier(ref));

class MiningState {
  final bool isMining;
  final Duration cooldown;
  MiningState({required this.isMining, required this.cooldown});
}

class MiningNotifier extends StateNotifier<MiningState> {
  final Ref ref;
  Timer? _timer;

  MiningNotifier(this.ref) : super(MiningState(isMining: false, cooldown: Duration.zero)) {
    _calculateCooldown();
    _tick(); // initial tick to catch up on missed time
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _calculateCooldown() {
    final profile = ref.read(profileProvider);
    if (profile?.lastMineTime != null) {
      final diff = DateTime.now().difference(profile!.lastMineTime!);
      if (diff.inHours < 24) {
        state = MiningState(isMining: true, cooldown: const Duration(hours: 24) - diff);
      } else {
        state = MiningState(isMining: false, cooldown: Duration.zero);
      }
    }
  }

  void _tick() {
    final now = DateTime.now();
    final profile = ref.read(profileProvider);
    final settingsBox = Hive.box('settings');
    
    if (profile?.lastMineTime != null) {
      final diffSinceStart = now.difference(profile!.lastMineTime!);
      
      if (diffSinceStart.inHours < 24) {
        // Mining is active
        state = MiningState(isMining: true, cooldown: const Duration(hours: 24) - diffSinceStart);
        
        int? lastSyncMs = settingsBox.get('lastSyncTime');
        DateTime lastSync = lastSyncMs != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs) 
            : profile!.lastMineTime!;
            
        // Ensure lastSync isn't before the current session start
        if (lastSync.isBefore(profile!.lastMineTime!)) {
            lastSync = profile!.lastMineTime!;
        }
        
        final uncreditedDuration = now.difference(lastSync);
        if (uncreditedDuration.inSeconds > 0) {
            double rewardPerSecond = 2.0 / 86400.0; // 2 GAMMA coins per 24 hours
            if (profile.hasPlantedTreeToday) rewardPerSecond *= 2; 
            
            double amount = uncreditedDuration.inSeconds * rewardPerSecond;
            ref.read(balanceProvider.notifier).addTokensSilent(amount);
            settingsBox.put('lastSyncTime', now.millisecondsSinceEpoch);
        }
      } else {
        // Mining finished
        int? lastSyncMs = settingsBox.get('lastSyncTime');
        DateTime lastSync = lastSyncMs != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs) 
            : profile!.lastMineTime!;
            
        if (lastSync.isBefore(profile!.lastMineTime!)) {
            lastSync = profile!.lastMineTime!;
        }
        
        final endTime = profile!.lastMineTime!.add(const Duration(hours: 24));
        if (lastSync.isBefore(endTime)) {
            final uncreditedDuration = endTime.difference(lastSync);
            if (uncreditedDuration.inSeconds > 0) {
                double rewardPerSecond = 2.0 / 86400.0;
                if (profile.hasPlantedTreeToday) rewardPerSecond *= 2; 
                double amount = uncreditedDuration.inSeconds * rewardPerSecond;
                ref.read(balanceProvider.notifier).addTokensSilent(amount);
                ref.read(balanceProvider.notifier).addTransaction('mine', amount, 'Daily Mining Completed');
                settingsBox.put('lastSyncTime', endTime.millisecondsSinceEpoch);
            }
        }
        state = MiningState(isMining: false, cooldown: Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startMining() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    if (state.isMining || state.cooldown.inSeconds > 0) return;

    final newStreak = profile.streak + 1;
    
    // We start mining now. Reset lastSyncTime so it starts counting from now.
    Hive.box('settings').put('lastSyncTime', DateTime.now().millisecondsSinceEpoch);
    
    int newLevel = profile.level;
    final balance = ref.read(balanceProvider);
    final projectedAllTime = balance.allTimeMined + 2.0;
    
    if (projectedAllTime >= 1000) newLevel = 3;
    else if (projectedAllTime >= 500) newLevel = 2;
    else if (projectedAllTime >= 100) newLevel = 1;

    ref.read(profileProvider.notifier).updateLevelAndStreak(newStreak, newLevel, DateTime.now());
    
    _calculateCooldown();
    _tick(); // initial tick
  }
}
