import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/loan_service.dart';
import '../models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<LoanModel> _emprestimos = [];
  List<LoanModel> get emprestimos => _emprestimos;

  LoanProvider() {
    _carregar();
  }

  void _carregar() {
    _emprestimos = _storage.buscarEmprestimos();
    notifyListeners();
  }

  Future<void> addLoan(LoanModel emprestimo) async {
    await _storage.salvarEmprestimo(emprestimo);
    _carregar();
  }

  Future<void> removeLoan(String id) async {
    await _storage.removerEmprestimo(id);
    _carregar();
  }

  /// Registra o pagamento de uma parcela
  Future<void> registrarPagamento(String id) async {
    final emp = _emprestimos.firstWhere((e) => e.id == id);
    if (emp.quitado) return;
    emp.parcelasPagas++;
    await _storage.atualizarEmprestimo(emp);
    _carregar();
  }

  // ── Agregados ──────────────────────────────────────

  /// Apenas empréstimos não quitados
  List<LoanModel> get emprestimosAtivos =>
      _emprestimos.where((e) => !e.quitado).toList();

  /// Soma do saldo devedor de todos os empréstimos ativos
  double get totalDividas => emprestimosAtivos.fold(
    0.0,
        (s, e) => s + e.saldoDevedor,
  );

  /// Soma das parcelas mensais de todos os empréstimos ativos
  double get parcelaMensalTotal => emprestimosAtivos.fold(
    0.0,
        (s, e) => s + e.parcelaValor,
  );

  /// Total de juros que serão pagos em todos os empréstimos ativos
  double get totalJurosFuturos => emprestimosAtivos.fold(
    0.0,
        (s, e) => s + LoanService.calcularTotalJuros(
      valorTotal: e.valorTotal,
      taxaMensal: e.taxaMensal,
      parcelas: e.parcelas,
    ),
  );
}