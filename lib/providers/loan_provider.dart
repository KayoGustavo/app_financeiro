import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/loan_service.dart';
import '../models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<LoanModel> _emprestimos = [];
  List<LoanModel> get emprestimos => _emprestimos;

  LoanProvider() {
    _carregar();
  }

  void _carregar() {
    _emprestimos = _storage.buscarEmprestimos();
    notifyListeners();
  }

  Future<void> addLoan(LoanModel e) async {
    await _storage.salvarEmprestimo(e);
    _sync.sincronizarEmprestimo(e);
    _carregar();
  }

  Future<void> removeLoan(String id) async {
    await _storage.removerEmprestimo(id);
    _sync.deletarEmprestimo(id);
    _carregar();
  }

  Future<void> registrarPagamento(String id) async {
    final emp = _emprestimos.firstWhere((e) => e.id == id);
    if (emp.quitado) return;
    emp.parcelasPagas++;
    await _storage.atualizarEmprestimo(emp);
    _sync.sincronizarEmprestimo(emp);
    _carregar();
  }

  List<LoanModel> get emprestimosAtivos =>
      _emprestimos.where((e) => !e.quitado).toList();

  double get totalDividas =>
      emprestimosAtivos.fold(0.0, (s, e) => s + e.saldoDevedor);

  double get parcelaMensalTotal =>
      emprestimosAtivos.fold(0.0, (s, e) => s + e.parcelaValor);

  double get totalJurosFuturos => emprestimosAtivos.fold(
    0.0,
        (s, e) => s + LoanService.calcularTotalJuros(
      valorTotal: e.valorTotal,
      taxaMensal: e.taxaMensal,
      parcelas: e.parcelas,
    ),
  );
}