// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************


class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 4;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      valorMeta: fields[2] as double,
      valorAtual: fields[3] as double,
      dataLimite: fields[4] as DateTime?,
      iconeCodePoint: fields[5] as int,
      cor: fields[6] as String,
      dataCriacao: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.valorMeta)
      ..writeByte(3)
      ..write(obj.valorAtual)
      ..writeByte(4)
      ..write(obj.dataLimite)
      ..writeByte(5)
      ..write(obj.iconeCodePoint)
      ..writeByte(6)
      ..write(obj.cor)
      ..writeByte(7)
      ..write(obj.dataCriacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GoalModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}