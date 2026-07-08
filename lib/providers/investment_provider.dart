import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/investment_service.dart';
import '../models/investment_model.dart';

class InvestmentProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<InvestmentModel> _investimentos = [];
  List<InvestmentModel> get investimentos => _investimentos;

  InvestmentProvider() {
    _carregar();
  }

  void _carregar() {
    _investimentos = _storage.buscarInvestimentos();
    notifyListeners();
  }

  Future<void> addInvestment(InvestmentModel investimento) async {
    await _storage.salvarInvestimento(investimento);
    _carregar();
  }

  Future<void> removeInvestment(String id) async {
    await _storage.removerInvestimento(id);
    _carregar();
  }

  // ── Cálculos agregados ──────────────────────────────

  /// Patrimônio total considerando o progresso atual de cada investimento
  double get patrimonioTotal {
    return InvestmentService.calcularPatrimonioTotal(_investimentos);
  }

  /// Total de dinheiro aportado (sem juros) até agora
  double get totalInvestidoGeral {
    return InvestmentService.calcularTotalInvestidoGeral(_investimentos);
  }

  /// Lucro acumulado (patrimônio - total investido)
  double get lucroTotal {
    return patrimonioTotal - totalInvestidoGeral;
  }

  /// Calcula o patrimônio atual de um investimento específico
  double patrimonioAtual(InvestmentModel investimento) {
    return InvestmentService.calcularPatrimonioAtual(investimento);
  }

  /// Calcula o valor final projetado de um investimento específico
  double valorFinalProjetado(InvestmentModel investimento) {
    return InvestmentService.calcularValorFinalProjetado(investimento);
  }
}