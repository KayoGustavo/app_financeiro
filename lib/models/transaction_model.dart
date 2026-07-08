import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Enum que define se a transação é receita ou despesa
@HiveType(typeId: 1)
enum TipoTransacao {
  @HiveField(0)
  receita,

  @HiveField(1)
  despesa,
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String descricao;

  @HiveField(2)
  late double valor;

  @HiveField(3)
  late TipoTransacao tipo;

  @HiveField(4)
  late String categoriaId;

  @HiveField(5)
  late DateTime data;

  @HiveField(6)
  String? observacao; // Campo opcional

  TransactionModel({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.categoriaId,
    required this.data,
    this.observacao,
  });

  /// Retorna true se for receita
  bool get isReceita => tipo == TipoTransacao.receita;

  /// Retorna true se for despesa
  bool get isDespesa => tipo == TipoTransacao.despesa;

  /// Valor com sinal: positivo para receita, negativo para despesa
  double get valorComSinal => isReceita ? valor : -valor;

  @override
  String toString() {
    return 'TransactionModel(id: $id, descricao: $descricao, valor: $valor, tipo: $tipo)';
  }
}