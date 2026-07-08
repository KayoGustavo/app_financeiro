import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<CategoryModel> _categorias = [];
  List<CategoryModel> get categorias => _categorias;

  CategoryProvider() {
    _carregar();
  }

  void _carregar() {
    _categorias = _storage.buscarCategorias();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel categoria) async {
    await _storage.salvarCategoria(categoria);
    _carregar();
  }

  Future<void> removeCategory(String id) async {
    await _storage.removerCategoria(id);
    _carregar();
  }

  CategoryModel? buscarPorId(String id) {
    return _storage.buscarCategoriaPorId(id);
  }
}