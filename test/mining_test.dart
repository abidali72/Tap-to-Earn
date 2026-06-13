import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

import 'package:ecomine/data/models/token_balance.dart';
import 'package:ecomine/data/models/user_profile.dart';
import 'package:ecomine/data/models/transaction_model.dart';
import 'package:ecomine/data/models/daily_task.dart';
import 'package:ecomine/providers/app_providers.dart';

void main() {
  setUpAll(() async {
    final directory = Directory.systemTemp.createTempSync();
    Hive.init(directory.path);
    
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(TokenBalanceAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(DailyTaskAdapter());

    await Hive.openBox<UserProfile>('profile');
    await Hive.openBox<TokenBalance>('balance');
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<DailyTask>('tasks');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('Balance updates correctly after mining', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final balanceNotifier = container.read(balanceProvider.notifier);
    
    expect(container.read(balanceProvider).total, 0.0);
    expect(container.read(balanceProvider).allTimeMined, 0.0);

    balanceNotifier.addTokens(0.5, 'mine', 'Daily Mining Session');

    expect(container.read(balanceProvider).total, 0.5);
    expect(container.read(balanceProvider).allTimeMined, 0.5);
  });

  test('Mining cooldown correctly prevents immediate consecutive sessions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final profileNotifier = container.read(profileProvider.notifier);
    profileNotifier.createWallet();

    final miningNotifier = container.read(miningProvider.notifier);
    
    expect(container.read(miningProvider).isMining, false);
    
    // Simulate mining by manually updating the last mine time
    profileNotifier.updateLevelAndStreak(1, 1, DateTime.now());
    
    // Re-instantiate the notifier to recalculate cooldown based on updated profile
    final newContainer = ProviderContainer(
      overrides: [
        miningProvider.overrideWith((ref) => MiningNotifier(ref))
      ]
    );
    
    final newMiningState = newContainer.read(miningProvider);
    
    // Since we just "mined", the cooldown should be > 0 (almost 24 hours)
    expect(newMiningState.cooldown.inSeconds, greaterThan(0));
    
    newContainer.dispose();
  });
}
