/// Resultado de uma simulação financeira.
/// Não precisa de Hive pois é calculado em tempo real.
class SimulationResultModel {
  final double totalInvestido;
  final double montanteFinal;
  final double lucro;
  final int? mesesParaMeta;
  final List<double> evolucaoMensal;

  // ── Campos de IR ─────────────────────────────────
  /// IR descontado sobre o lucro (0 se isento)
  final double irDescontado;

  /// Montante líquido após IR
  final double montanteLiquido;

  /// Alíquota de IR aplicada (ex: 0.15 = 15%)
  final double aliquotaIR;

  const SimulationResultModel({
    required this.totalInvestido,
    required this.montanteFinal,
    required this.lucro,
    this.mesesParaMeta,
    this.evolucaoMensal = const [],
    this.irDescontado = 0,
    this.montanteLiquido = 0,
    this.aliquotaIR = 0,
  });

  /// Lucro líquido após IR
  double get lucroLiquido => montanteLiquido - totalInvestido;

  /// Rentabilidade total bruta em %
  double get rentabilidadePercent {
    if (totalInvestido == 0) return 0;
    return (lucro / totalInvestido) * 100;
  }

  /// Rentabilidade líquida (após IR) em %
  double get rentabilidadeLiquidaPercent {
    if (totalInvestido == 0) return 0;
    return (lucroLiquido / totalInvestido) * 100;
  }

  /// Tem IR descontado?
  bool get temIR => irDescontado > 0;

  /// Tempo formatado em anos e meses
  String get tempoFormatado {
    if (mesesParaMeta == null) return '';
    final anos = mesesParaMeta! ~/ 12;
    final meses = mesesParaMeta! % 12;
    if (anos == 0) return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    if (meses == 0) return '$anos ${anos == 1 ? 'ano' : 'anos'}';
    return '$anos ${anos == 1 ? 'ano' : 'anos'} e $meses ${meses == 1 ? 'mês' : 'meses'}';
  }

  bool get metaAtingida => mesesParaMeta != null;

  @override
  String toString() {
    return 'SimulationResult(investido: $totalInvestido, montante: $montanteFinal, liquido: $montanteLiquido)';
  }
}