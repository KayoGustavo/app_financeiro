// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 5;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      id: fields[0] as String,
      descricao: fields[1] as String,
      tipoId: fields[2] as String,
      valorTotal: fields[3] as double,
      taxaMensal: fields[4] as double,
      parcelas: fields[5] as int,
      parcelasPagas: fields[6] as int,
      dataInicio: fields[7] as DateTime,
      credor: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descricao)
      ..writeByte(2)
      ..write(obj.tipoId)
      ..writeByte(3)
      ..write(obj.valorTotal)
      ..writeByte(4)
      ..write(obj.taxaMensal)
      ..writeByte(5)
      ..write(obj.parcelas)
      ..writeByte(6)
      ..write(obj.parcelasPagas)
      ..writeByte(7)
      ..write(obj.dataInicio)
      ..writeByte(8)
      ..write(obj.credor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LoanModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}