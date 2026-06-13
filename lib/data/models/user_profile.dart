import 'package:hive/hive.dart';

class UserProfile {
  final String id;
  final String inviteCode;
  final int streak;
  final int level;
  final DateTime? lastMineTime;
  final bool hasPlantedTreeToday;
  final DateTime joinDate;

  UserProfile({
    required this.id,
    required this.inviteCode,
    required this.streak,
    required this.level,
    this.lastMineTime,
    this.hasPlantedTreeToday = false,
    required this.joinDate,
  });

  UserProfile copyWith({
    String? id,
    String? inviteCode,
    int? streak,
    int? level,
    DateTime? lastMineTime,
    bool? hasPlantedTreeToday,
    DateTime? joinDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      lastMineTime: lastMineTime ?? this.lastMineTime,
      hasPlantedTreeToday: hasPlantedTreeToday ?? this.hasPlantedTreeToday,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    return UserProfile(
      id: reader.readString(),
      inviteCode: reader.readString(),
      streak: reader.readInt(),
      level: reader.readInt(),
      lastMineTime: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      hasPlantedTreeToday: reader.readBool(),
      joinDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.inviteCode);
    writer.writeInt(obj.streak);
    writer.writeInt(obj.level);
    writer.writeBool(obj.lastMineTime != null);
    if (obj.lastMineTime != null) {
      writer.writeInt(obj.lastMineTime!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.hasPlantedTreeToday);
    writer.writeInt(obj.joinDate.millisecondsSinceEpoch);
  }
}
