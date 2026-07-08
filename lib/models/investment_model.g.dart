// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestmentModelAdapter extends TypeAdapter<InvestmentModel> {
  @override
  final int typeId = 3;

  @override
  InvestmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestmentModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      valorInicial: fields[2] as double,
      aporteMensal: fields[3] as double,
      taxaMensal: fields[4] as double,
      tempoMeses: fields[5] as int,
      dataInicio: fields[6] as DateTime,
      descricao: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InvestmentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.valorInicial)
      ..writeByte(3)
      ..write(obj.aporteMensal)
      ..writeByte(4)
      ..write(obj.taxaMensal)
      ..writeByte(5)
      ..write(obj.tempoMeses)
      ..writeByte(6)
      ..write(obj.dataInicio)
      ..writeByte(7)
      ..write(obj.descricao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
