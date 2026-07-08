import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/investment_model.dart';
import '../models/goal_model.dart';


/// Serviço responsável por toda persistência local usando Hive.
/// Cada entidade tem sua própria Box (equivalente a uma tabela).
class StorageService {
  static const String _boxTransacoes = 'transacoes';
  static const String _boxCategorias = 'categorias';
  static const String _boxInvestimentos = 'investimentos';
  static const String _boxMetas = 'metas';

  // ─────────────────────────────────────────
  // INICIALIZAÇÃO
  // ─────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TipoTransacaoAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(InvestmentModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());

    await Hive.openBox<CategoryModel>(_boxCategorias);
    await Hive.openBox<TransactionModel>(_boxTransacoes);
    await Hive.openBox<InvestmentModel>(_boxInvestimentos);
    await Hive.openBox<GoalModel>(_boxMetas);

    await _inicializarCategoriasPadrao();
  }

  static Future<void> _inicializarCategoriasPadrao() async {
    final box = Hive.box<CategoryModel>(_boxCategorias);
    if (box.isEmpty) {
      for (final categoria in CategoryModel.categoriasPadrao) {
        await box.put(categoria.id, categoria);
      }
    }
  }

  // ─────────────────────────────────────────
  // TRANSAÇÕES
  // ─────────────────────────────────────────

  Box<TransactionModel> get _transacoesBox =>
      Hive.box<TransactionModel>(_boxTransacoes);

  Future<void> salvarTransacao(TransactionModel transacao) async {
    await _transacoesBox.put(transacao.id, transacao);
  }

  Future<void> removerTransacao(String id) async {
    await _transacoesBox.delete(id);
  }

  Future<void> atualizarTransacao(TransactionModel transacao) async {
    await _transacoesBox.put(transacao.id, transacao);
  }

  List<TransactionModel> buscarTransacoes() {
    return _transacoesBox.values.toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  List<TransactionModel> buscarTransacoesPorMes(int ano, int mes) {
    return buscarTransacoes()
        .where((t) => t.data.year == ano && t.data.month == mes)
        .toList();
  }

  // ─────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────

  Box<CategoryModel> get _categoriasBox =>
      Hive.box<CategoryModel>(_boxCategorias);

  Future<void> salvarCategoria(CategoryModel categoria) async {
    await _categoriasBox.put(categoria.id, categoria);
  }

  Future<void> removerCategoria(String id) async {
    await _categoriasBox.delete(id);
  }

  List<CategoryModel> buscarCategorias() {
    return _categoriasBox.values.toList();
  }

  CategoryModel? buscarCategoriaPorId(String id) {
    return _categoriasBox.get(id);
  }

  // ─────────────────────────────────────────
  // INVESTIMENTOS
  // ─────────────────────────────────────────

  Box<InvestmentModel> get _investimentosBox =>
      Hive.box<InvestmentModel>(_boxInvestimentos);

  Future<void> salvarInvestimento(InvestmentModel investimento) async {
    await _investimentosBox.put(investimento.id, investimento);
  }

  Future<void> removerInvestimento(String id) async {
    await _investimentosBox.delete(id);
  }

  List<InvestmentModel> buscarInvestimentos() {
    return _investimentosBox.values.toList();
  }

  // ─────────────────────────────────────────
  // METAS
  // ─────────────────────────────────────────

  Box<GoalModel> get _metasBox => Hive.box<GoalModel>(_boxMetas);

  Future<void> salvarMeta(GoalModel meta) async {
    await _metasBox.put(meta.id, meta);
  }

  Future<void> removerMeta(String id) async {
    await _metasBox.delete(id);
  }

  Future<void> atualizarMeta(GoalModel meta) async {
    await _metasBox.put(meta.id, meta);
  }

  List<GoalModel> buscarMetas() {
    return _metasBox.values.toList()
      ..sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));
  }

  // ─────────────────────────────────────────
  // UTILITÁRIOS
  // ─────────────────────────────────────────

  Future<void> limparTudo() async {
    await _transacoesBox.clear();
    await _categoriasBox.clear();
    await _investimentosBox.clear();
    await _metasBox.clear();
    await _inicializarCategoriasPadrao();
  }

  Future<void> fechar() async {
    await Hive.close();
  }
}