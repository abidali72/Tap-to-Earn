import 'package:hive/hive.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final DateTime timestamp;
  final String description;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required DateTime timestamp,
    required this.description,
  }) : timestamp = timestamp;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    return TransactionModel(
      id: reader.readString(),
      type: reader.readString(),
      amount: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.type);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.description);
  }
}
