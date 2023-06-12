// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryQuestionAdapter extends TypeAdapter<SummaryQuestion> {
  @override
  final int typeId = 0;

  @override
  SummaryQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummaryQuestion()
      ..summary = fields[0] as String
      ..question = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, SummaryQuestion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.summary)
      ..writeByte(1)
      ..write(obj.question);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
