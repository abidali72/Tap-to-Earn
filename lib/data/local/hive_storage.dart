import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/token_balance.dart';
import '../models/transaction_model.dart';
import '../models/daily_task.dart';

class HiveStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(TokenBalanceAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(DailyTaskAdapter());

    await Hive.openBox<UserProfile>('profile');
    await Hive.openBox<TokenBalance>('balance');
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<DailyTask>('tasks');
    await Hive.openBox('settings');
  }
}
