import '../models/simulation_result_model.dart';

/// Serviço responsável pelos cálculos das 3 simulações financeiras.
class SimulationService {
  // ── Simulação 1: Montante final ───────────────────────────────────────────

  /// Calcula quanto você acumula investindo X por Y meses com taxa Z.
  static SimulationResultModel simularMontante({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int prazoMeses,
  }) {
    double montante = valorInicial;
    double totalInvestido = valorInicial;
    final evolucao = <double>[montante];

    for (int i = 0; i < prazoMeses; i++) {
      montante = montante * (1 + taxaMensal) + aporteMensal;
      totalInvestido += aporteMensal;
      evolucao.add(montante);
    }

    return SimulationResultModel(
      totalInvestido: totalInvestido,
      montanteFinal: montante,
      lucro: montante - totalInvestido,
      evolucaoMensal: evolucao,
    );
  }

  // ── Simulação 2: Tempo para atingir meta ──────────────────────────────────

  /// Calcula em quantos meses você atinge uma meta financeira.
  static SimulationResultModel simularMeta({
    required double meta,
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    int limiteMaxMeses = 1200,
  }) {
    double montante = valorInicial;
    double totalInvestido = valorInicial;
    int meses = 0;
    final evolucao = <double>[montante];

    while (montante < meta && meses < limiteMaxMeses) {
      montante = montante * (1 + taxaMensal) + aporteMensal;
      totalInvestido += aporteMensal;
      meses++;
      evolucao.add(montante);
    }

    return SimulationResultModel(
      totalInvestido: totalInvestido,
      montanteFinal: montante,
      lucro: montante - totalInvestido,
      mesesParaMeta: meses < limiteMaxMeses ? meses : null,
      evolucaoMensal: evolucao,
    );
  }

  // ── Simulação 3: Com base na sobra do salário ─────────────────────────────

  /// Calcula em quantos meses você atinge a meta
  /// investindo a sobra (salário - gastos).
  static SimulationResultModel simularSobra({
    required double salario,
    required double gastoMensal,
    required double valorInicial,
    required double taxaMensal,
    required double meta,
    int limiteMaxMeses = 1200,
  }) {
    final sobra = salario - gastoMensal;

    if (sobra <= 0) {
      return SimulationResultModel(
        totalInvestido: valorInicial,
        montanteFinal: valorInicial,
        lucro: 0,
        mesesParaMeta: null,
        evolucaoMensal: [valorInicial],
      );
    }

    return simularMeta(
      meta: meta,
      valorInicial: valorInicial,
      aporteMensal: sobra,
      taxaMensal: taxaMensal,
      limiteMaxMeses: limiteMaxMeses,
    );
  }
}