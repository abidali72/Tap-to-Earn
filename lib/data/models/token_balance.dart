import 'package:hive/hive.dart';

class TokenBalance {
  final double total;
  final double allTimeMined;

  const TokenBalance({
    required this.total,
    required this.allTimeMined,
  });

  TokenBalance copyWith({
    double? total,
    double? allTimeMined,
  }) {
    return TokenBalance(
      total: total ?? this.total,
      allTimeMined: allTimeMined ?? this.allTimeMined,
    );
  }
}

class TokenBalanceAdapter extends TypeAdapter<TokenBalance> {
  @override
  final int typeId = 1;

  @override
  TokenBalance read(BinaryReader reader) {
    return TokenBalance(
      total: reader.readDouble(),
      allTimeMined: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, TokenBalance obj) {
    writer.writeDouble(obj.total);
    writer.writeDouble(obj.allTimeMined);
  }
}
