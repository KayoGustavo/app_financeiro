import 'package:hive/hive.dart';

part 'investment_model.g.dart';

@HiveType(typeId: 3)
class InvestmentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late double valorInicial;

  @HiveField(3)
  late double aporteMensal;

  /// Taxa de rendimento ao mês em decimal (ex: 0.008 = 0.8% ao mês)
  @HiveField(4)
  late double taxaMensal;

  /// Prazo total em meses
  @HiveField(5)
  late int tempoMeses;

  /// Data de início do investimento
  @HiveField(6)
  late DateTime dataInicio;

  @HiveField(7)
  String? descricao; // Ex: 'Tesouro Selic', 'CDB', etc.

  InvestmentModel({
    required this.id,
    required this.nome,
    required this.valorInicial,
    required this.aporteMensal,
    required this.taxaMensal,
    required this.tempoMeses,
    required this.dataInicio,
    this.descricao,
  });

  /// Converte taxa anual (%) para taxa mensal decimal
  /// Útil quando o usuário informa a taxa anual
  static double taxaAnualParaMensal(double taxaAnualPercent) {
    // Fórmula: (1 + taxa_anual)^(1/12) - 1
    return (1 + taxaAnualPercent / 100) * (1 / 12) - 1;
  }

  /// Taxa mensal em porcentagem (para exibição)
  double get taxaMensalPercent => taxaMensal * 100;

  /// Quantos meses já se passaram desde o início
  int get mesesDecorridos {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataInicio);
    return (diferenca.inDays / 30).floor().clamp(0, tempoMeses);
  }

  /// Percentual de conclusão do prazo (0.0 a 1.0)
  double get progresso => tempoMeses > 0 ? mesesDecorridos / tempoMeses : 0.0;

  @override
  String toString() {
    return 'InvestmentModel(id: $id, nome: $nome, valorInicial: $valorInicial)';
  }
}