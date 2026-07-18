import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<GoalModel> _metas = [];
  List<GoalModel> get metas => _metas;

  GoalProvider() {
    _carregar();
  }

  void _carregar() {
    _metas = _storage.buscarMetas();
    notifyListeners();
  }

  Future<void> addGoal(GoalModel m) async {
    await _storage.salvarMeta(m);
    _sync.sincronizarMeta(m);
    _carregar();
  }

  Future<void> removeGoal(String id) async {
    await _storage.removerMeta(id);
    _sync.deletarMeta(id);
    _carregar();
  }

  Future<void> updateGoal(GoalModel m) async {
    await _storage.atualizarMeta(m);
    _sync.sincronizarMeta(m);
    _carregar();
  }

  Future<void> adicionarValor(String id, double valor) async {
    final meta = _metas.firstWhere((m) => m.id == id);
    meta.valorAtual += valor;
    await _storage.atualizarMeta(meta);
    _sync.sincronizarMeta(meta);
    _carregar();
  }

  int get totalMetas => _metas.length;
  int get metasConcluidas => _metas.where((m) => m.concluida).length;
  double get progressoMedio {
    if (_metas.isEmpty) return 0;
    return _metas.fold(0.0, (s, m) => s + m.progresso) / _metas.length;
  }
}