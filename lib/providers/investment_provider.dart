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

  Future<void> updateInvestment(InvestmentModel investimento) async {
    await _storage.salvarInvestimento(investimento); // put sobrescreve pelo id
    _carregar();
  }

  // ── Cálculos ──────────────────────────────────────

  double get patrimonioTotal =>
      InvestmentService.calcularPatrimonioTotal(_investimentos);

  double get totalInvestidoGeral =>
      InvestmentService.calcularTotalInvestidoGeral(_investimentos);

  double get lucroTotal => patrimonioTotal - totalInvestidoGeral;

  double patrimonioAtual(InvestmentModel inv) =>
      InvestmentService.calcularPatrimonioAtual(inv);

  double valorFinalProjetado(InvestmentModel inv) =>
      InvestmentService.calcularValorFinalProjetado(inv);
}