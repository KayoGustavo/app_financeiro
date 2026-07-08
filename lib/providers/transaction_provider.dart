import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<TransactionModel> _transacoes = [];
  List<TransactionModel> get transacoes => _transacoes;

  TransactionProvider() {
    _carregar();
  }

  void _carregar() {
    _transacoes = _storage.buscarTransacoes();
    notifyListeners();
  }

  // ── Totais gerais ─────────────────────────────────

  double get saldoTotal {
    return _transacoes.fold(0.0, (soma, t) => soma + t.valorComSinal);
  }

  double get totalReceitas {
    return _transacoes
        .where((t) => t.isReceita)
        .fold(0.0, (soma, t) => soma + t.valor);
  }

  double get totalDespesas {
    return _transacoes
        .where((t) => t.isDespesa)
        .fold(0.0, (soma, t) => soma + t.valor);
  }

  /// Diferença entre receitas e despesas (positivo = sobrou, negativo = deficit)
  double get deltaMes => totalReceitas - totalDespesas;

  // ── Gastos por categoria ──────────────────────────

  /// Retorna um mapa de categoriaId → soma das despesas daquela categoria.
  /// Ordenado do maior para o menor valor.
  Map<String, double> get gastosPorCategoria {
    final mapa = <String, double>{};

    for (final tx in _transacoes.where((t) => t.isDespesa)) {
      mapa[tx.categoriaId] = (mapa[tx.categoriaId] ?? 0) + tx.valor;
    }

    // Ordena do maior para o menor
    final ordenado = Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return ordenado;
  }

  // ── CRUD ──────────────────────────────────────────

  Future<void> addTransaction(TransactionModel transacao) async {
    await _storage.salvarTransacao(transacao);
    _carregar();
  }

  Future<void> removeTransaction(String id) async {
    await _storage.removerTransacao(id);
    _carregar();
  }

  Future<void> updateTransaction(TransactionModel transacao) async {
    await _storage.atualizarTransacao(transacao);
    _carregar();
  }
}