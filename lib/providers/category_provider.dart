import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<CategoryModel> _categorias = [];
  List<CategoryModel> get categorias => _categorias;

  CategoryProvider() {
    _carregar();
  }

  void _carregar() {
    _categorias = _storage.buscarCategorias();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel c) async {
    await _storage.salvarCategoria(c);
    _sync.sincronizarCategoria(c);
    _carregar();
  }

  Future<void> removeCategory(String id) async {
    await _storage.removerCategoria(id);
    _sync.deletarCategoria(id);
    _carregar();
  }

  CategoryModel? buscarPorId(String id) =>
      _storage.buscarCategoriaPorId(id);
}