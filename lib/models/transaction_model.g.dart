// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      descricao: fields[1] as String,
      valor: fields[2] as double,
      tipo: fields[3] as TipoTransacao,
      categoriaId: fields[4] as String,
      data: fields[5] as DateTime,
      observacao: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descricao)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.tipo)
      ..writeByte(4)
      ..write(obj.categoriaId)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.observacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoTransacaoAdapter extends TypeAdapter<TipoTransacao> {
  @override
  final int typeId = 1;

  @override
  TipoTransacao read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoTransacao.receita;
      case 1:
        return TipoTransacao.despesa;
      default:
        return TipoTransacao.receita;
    }
  }

  @override
  void write(BinaryWriter writer, TipoTransacao obj) {
    switch (obj) {
      case TipoTransacao.receita:
        writer.writeByte(0);
        break;
      case TipoTransacao.despesa:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoTransacaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
