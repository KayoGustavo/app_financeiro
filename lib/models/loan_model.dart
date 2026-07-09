import 'package:hive/hive.dart';

part 'loan_model.g.dart';

@HiveType(typeId: 5)
class LoanModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String descricao;

  @HiveField(2)
  late String tipoId; // referência ao LoanTypes

  @HiveField(3)
  late double valorTotal; // valor emprestado

  @HiveField(4)
  late double taxaMensal; // decimal (ex: 0.06 = 6%)

  @HiveField(5)
  late int parcelas; // total de parcelas

  @HiveField(6)
  late int parcelasPagas;

  @HiveField(7)
  late DateTime dataInicio;

  @HiveField(8)
  late String credor; // ex: 'Banco Itaú', 'Amigo João'

  LoanModel({
    required this.id,
    required this.descricao,
    required this.tipoId,
    required this.valorTotal,
    required this.taxaMensal,
    required this.parcelas,
    this.parcelasPagas = 0,
    required this.dataInicio,
    required this.credor,
  });

  /// Valor da parcela mensal pela Tabela Price
  /// PMT = PV × (i × (1+i)^n) / ((1+i)^n - 1)
  double get parcelaValor {
    if (taxaMensal == 0) return valorTotal / parcelas;
    final i = taxaMensal;
    final n = parcelas;
    final fator = (i * (1 + i) * n) / ((1 + i) * n - 1);
    return valorTotal * fator;
  }

  /// Total que será pago (parcela × número de parcelas)
  double get totalPago => parcelaValor * parcelas;

  /// Total de juros pagos
  double get totalJuros => totalPago - valorTotal;

  /// Valor já pago até agora
  double get valorPagoAtual => parcelaValor * parcelasPagas;

  /// Saldo devedor restante
  double get saldoDevedor => totalPago - valorPagoAtual;

  /// Progresso de quitação (0.0 a 1.0)
  double get progresso =>
      parcelas > 0 ? (parcelasPagas / parcelas).clamp(0.0, 1.0) : 0.0;

  /// Se o empréstimo está quitado
  bool get quitado => parcelasPagas >= parcelas;

  /// Parcelas restantes
  int get parcelasRestantes => (parcelas - parcelasPagas).clamp(0, parcelas);

  /// Taxa mensal em %
  double get taxaMensalPercent => taxaMensal * 100;
}