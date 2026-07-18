import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<TransactionModel> _transacoes = [];
  List<TransactionModel> get transacoes => _transacoes;

  TransactionProvider() {
    _carregar();
  }

  void _carregar() {
    _transacoes = _storage.buscarTransacoes();
    notifyListeners();
  }

  double get saldoTotal =>
      _transacoes.fold(0.0, (s, t) => s + t.valorComSinal);

  double get totalReceitas => _transacoes
      .where((t) => t.isReceita)
      .fold(0.0, (s, t) => s + t.valor);

  double get totalDespesas => _transacoes
      .where((t) => t.isDespesa)
      .fold(0.0, (s, t) => s + t.valor);

  double get deltaMes => totalReceitas - totalDespesas;

  Map<String, double> get gastosPorCategoria {
    final mapa = <String, double>{};
    for (final tx in _transacoes.where((t) => t.isDespesa)) {
      mapa[tx.categoriaId] = (mapa[tx.categoriaId] ?? 0) + tx.valor;
    }
    return Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> addTransaction(TransactionModel t) async {
    await _storage.salvarTransacao(t);
    _sync.sincronizarTransacao(t); // async sem await — não bloqueia UI
    _carregar();
  }

  Future<void> removeTransaction(String id) async {
    await _storage.removerTransacao(id);
    _sync.deletarTransacao(id);
    _carregar();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await _storage.atualizarTransacao(t);
    _sync.sincronizarTransacao(t);
    _carregar();
  }
}