import '../models/investment_model.dart';
import '../models/simulation_result_model.dart';

/// Serviço responsável pelos cálculos de investimentos e IR.
class InvestmentService {
  // ── Juros compostos ───────────────────────────────

  static double calcularMontante({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int tempoMeses,
  }) {
    double montante = valorInicial;
    for (int i = 0; i < tempoMeses; i++) {
      montante = montante * (1 + taxaMensal) + aporteMensal;
    }
    return montante;
  }

  static double calcularTotalInvestido({
    required double valorInicial,
    required double aporteMensal,
    required int tempoMeses,
  }) {
    return valorInicial + (aporteMensal * tempoMeses);
  }

  static double calcularLucro({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int tempoMeses,
  }) {
    final montante = calcularMontante(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      tempoMeses: tempoMeses,
    );
    final investido = calcularTotalInvestido(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      tempoMeses: tempoMeses,
    );
    return montante - investido;
  }

  // ── IR (Imposto de Renda) ─────────────────────────

  /// Tabela regressiva de IR baseada no prazo em dias
  static double aliquotaIR(int dias) {
    if (dias <= 180) return 0.225;
    if (dias <= 360) return 0.20;
    if (dias <= 720) return 0.175;
    return 0.15;
  }

  /// Calcula o IR a ser pago sobre o lucro
  static double calcularIR(double lucro, int dias) {
    if (lucro <= 0) return 0;
    return lucro * aliquotaIR(dias);
  }

  /// Calcula o resultado completo com IR descontado
  static SimulationResultModel calcularComIR({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int prazoMeses,
    required bool temIR,
    required bool isento,
  }) {
    final montante = calcularMontante(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      tempoMeses: prazoMeses,
    );
    final investido = calcularTotalInvestido(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      tempoMeses: prazoMeses,
    );
    final lucro = montante - investido;
    final dias = prazoMeses * 30;
    final evolucao = calcularEvolucaoMensal(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      tempoMeses: prazoMeses,
    );

    double ir = 0;
    double liquido = montante;
    double aliquota = 0;

    if (temIR && !isento) {
      aliquota = aliquotaIR(dias);
      ir = calcularIR(lucro, dias);
      liquido = montante - ir;
    } else {
      // Isento de IR — montante líquido = montante bruto
      liquido = montante;
    }

    return SimulationResultModel(
      totalInvestido: investido,
      montanteFinal: montante,
      lucro: lucro,
      irDescontado: ir,
      montanteLiquido: liquido,
      aliquotaIR: aliquota,
      evolucaoMensal: evolucao,
    );
  }

  // ── Portfólio ─────────────────────────────────────

  static double calcularPatrimonioAtual(InvestmentModel investimento) {
    return calcularMontante(
      valorInicial: investimento.valorInicial,
      aporteMensal: investimento.aporteMensal,
      taxaMensal: investimento.taxaMensal,
      tempoMeses: investimento.mesesDecorridos,
    );
  }

  static double calcularValorFinalProjetado(InvestmentModel investimento) {
    return calcularMontante(
      valorInicial: investimento.valorInicial,
      aporteMensal: investimento.aporteMensal,
      taxaMensal: investimento.taxaMensal,
      tempoMeses: investimento.tempoMeses,
    );
  }

  static List<double> calcularEvolucaoMensal({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int tempoMeses,
  }) {
    final evolucao = <double>[valorInicial];
    double montante = valorInicial;
    for (int i = 0; i < tempoMeses; i++) {
      montante = montante * (1 + taxaMensal) + aporteMensal;
      evolucao.add(montante);
    }
    return evolucao;
  }

  static double calcularPatrimonioTotal(List<InvestmentModel> investimentos) {
    return investimentos.fold(
      0.0,
          (soma, inv) => soma + calcularPatrimonioAtual(inv),
    );
  }

  static double calcularTotalInvestidoGeral(
      List<InvestmentModel> investimentos) {
    return investimentos.fold(0.0, (soma, inv) {
      return soma +
          calcularTotalInvestido(
            valorInicial: inv.valorInicial,
            aporteMensal: inv.aporteMensal,
            tempoMeses: inv.mesesDecorridos,
          );
    });
  }
}