import 'package:hive/hive.dart';

class DailyTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime date;

  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.date,
  });

  DailyTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? date,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }
}

class DailyTaskAdapter extends TypeAdapter<DailyTask> {
  @override
  final int typeId = 3;

  @override
  DailyTask read(BinaryReader reader) {
    return DailyTask(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      isCompleted: reader.readBool(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, DailyTask obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
  }
}
