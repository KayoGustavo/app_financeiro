import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/investment_service.dart';
import '../models/investment_model.dart';

class InvestmentProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<InvestmentModel> _investimentos = [];
  List<InvestmentModel> get investimentos => _investimentos;

  InvestmentProvider() {
    _carregar();
  }

  void _carregar() {
    _investimentos = _storage.buscarInvestimentos();
    notifyListeners();
  }

  Future<void> addInvestment(InvestmentModel i) async {
    await _storage.salvarInvestimento(i);
    _sync.sincronizarInvestimento(i);
    _carregar();
  }

  Future<void> removeInvestment(String id) async {
    await _storage.removerInvestimento(id);
    _sync.deletarInvestimento(id);
    _carregar();
  }

  Future<void> updateInvestment(InvestmentModel i) async {
    await _storage.salvarInvestimento(i);
    _sync.sincronizarInvestimento(i);
    _carregar();
  }

  double get patrimonioTotal =>
      InvestmentService.calcularPatrimonioTotal(_investimentos);

  double get totalInvestidoGeral =>
      InvestmentService.calcularTotalInvestidoGeral(_investimentos);

  double get lucroTotal => patrimonioTotal - totalInvestidoGeral;

  double patrimonioAtual(InvestmentModel i) =>
      InvestmentService.calcularPatrimonioAtual(i);

  double valorFinalProjetado(InvestmentModel i) =>
      InvestmentService.calcularValorFinalProjetado(i);
}