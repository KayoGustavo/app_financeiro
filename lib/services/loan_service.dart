/// Serviço de cálculos de empréstimos usando Tabela Price.
class LoanService {
  LoanService._();

  /// Calcula o valor da parcela mensal (Tabela Price)
  /// PMT = PV × (i × (1+i)^n) / ((1+i)^n - 1)
  static double calcularParcela({
    required double valorTotal,
    required double taxaMensal,
    required int parcelas,
  }) {
    if (taxaMensal == 0) return valorTotal / parcelas;
    final i = taxaMensal;
    final n = parcelas;
    final potencia = (1 + i) * n;
    return valorTotal * (i * potencia) / (potencia - 1);
  }

  /// Total pago ao final do contrato
  static double calcularTotalPago({
    required double valorTotal,
    required double taxaMensal,
    required int parcelas,
  }) {
    return calcularParcela(
      valorTotal: valorTotal,
      taxaMensal: taxaMensal,
      parcelas: parcelas,
    ) *
        parcelas;
  }

  /// Total de juros pagos
  static double calcularTotalJuros({
    required double valorTotal,
    required double taxaMensal,
    required int parcelas,
  }) {
    return calcularTotalPago(
      valorTotal: valorTotal,
      taxaMensal: taxaMensal,
      parcelas: parcelas,
    ) -
        valorTotal;
  }

  /// Saldo devedor após N parcelas pagas
  static double calcularSaldoDevedor({
    required double valorTotal,
    required double taxaMensal,
    required int parcelas,
    required int parcelasPagas,
  }) {
    final parcela = calcularParcela(
      valorTotal: valorTotal,
      taxaMensal: taxaMensal,
      parcelas: parcelas,
    );
    final totalPago = parcela * parcelasPagas;
    final totalContrato = parcela * parcelas;
    return (totalContrato - totalPago).clamp(0, double.infinity);
  }

  /// Classifica a taxa de empréstimo
  /// Retorna: 'excelente', 'moderada' ou 'alta'
  static String classificarTaxa(double taxaMensal) {
    final percent = taxaMensal * 100;
    if (percent <= 2.5) return 'excelente';
    if (percent <= 5.0) return 'moderada';
    return 'alta';
  }

  /// Quanto o usuário paga a mais em relação ao que pegou (em %)
  static double percentualCusto({
    required double valorTotal,
    required double taxaMensal,
    required int parcelas,
  }) {
    final total = calcularTotalPago(
      valorTotal: valorTotal,
      taxaMensal: taxaMensal,
      parcelas: parcelas,
    );
    return ((total - valorTotal) / valorTotal) * 100;
  }
}