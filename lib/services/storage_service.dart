import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/investment_model.dart';
import '../models/goal_model.dart';
import '../models/loan_model.dart';

class StorageService {
  static const String _boxTransacoes = 'transacoes';
  static const String _boxCategorias = 'categorias';
  static const String _boxInvestimentos = 'investimentos';
  static const String _boxMetas = 'metas';
  static const String _boxEmprestimos = 'emprestimos';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TipoTransacaoAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(InvestmentModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(LoanModelAdapter());

    await Hive.openBox<CategoryModel>(_boxCategorias);
    await Hive.openBox<TransactionModel>(_boxTransacoes);
    await Hive.openBox<InvestmentModel>(_boxInvestimentos);
    await Hive.openBox<GoalModel>(_boxMetas);
    await Hive.openBox<LoanModel>(_boxEmprestimos);

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

  // ── Transações ────────────────────────────────────

  Box<TransactionModel> get _transacoesBox =>
      Hive.box<TransactionModel>(_boxTransacoes);

  Future<void> salvarTransacao(TransactionModel t) async =>
      _transacoesBox.put(t.id, t);

  Future<void> removerTransacao(String id) async =>
      _transacoesBox.delete(id);

  Future<void> atualizarTransacao(TransactionModel t) async =>
      _transacoesBox.put(t.id, t);

  List<TransactionModel> buscarTransacoes() => _transacoesBox.values.toList()
    ..sort((a, b) => b.data.compareTo(a.data));

  // ── Categorias ────────────────────────────────────

  Box<CategoryModel> get _categoriasBox =>
      Hive.box<CategoryModel>(_boxCategorias);

  Future<void> salvarCategoria(CategoryModel c) async =>
      _categoriasBox.put(c.id, c);

  Future<void> removerCategoria(String id) async =>
      _categoriasBox.delete(id);

  List<CategoryModel> buscarCategorias() =>
      _categoriasBox.values.toList();

  CategoryModel? buscarCategoriaPorId(String id) =>
      _categoriasBox.get(id);

  // ── Investimentos ─────────────────────────────────

  Box<InvestmentModel> get _investimentosBox =>
      Hive.box<InvestmentModel>(_boxInvestimentos);

  Future<void> salvarInvestimento(InvestmentModel i) async =>
      _investimentosBox.put(i.id, i);

  Future<void> removerInvestimento(String id) async =>
      _investimentosBox.delete(id);

  List<InvestmentModel> buscarInvestimentos() =>
      _investimentosBox.values.toList();

  // ── Metas ─────────────────────────────────────────

  Box<GoalModel> get _metasBox => Hive.box<GoalModel>(_boxMetas);

  Future<void> salvarMeta(GoalModel m) async => _metasBox.put(m.id, m);

  Future<void> removerMeta(String id) async => _metasBox.delete(id);

  Future<void> atualizarMeta(GoalModel m) async => _metasBox.put(m.id, m);

  List<GoalModel> buscarMetas() => _metasBox.values.toList()
    ..sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));

  // ── Empréstimos ───────────────────────────────────

  Box<LoanModel> get _emprestimosBox =>
      Hive.box<LoanModel>(_boxEmprestimos);

  Future<void> salvarEmprestimo(LoanModel e) async =>
      _emprestimosBox.put(e.id, e);

  Future<void> removerEmprestimo(String id) async =>
      _emprestimosBox.delete(id);

  Future<void> atualizarEmprestimo(LoanModel e) async =>
      _emprestimosBox.put(e.id, e);

  List<LoanModel> buscarEmprestimos() => _emprestimosBox.values.toList()
    ..sort((a, b) => a.dataInicio.compareTo(b.dataInicio));

  // ── Utilitários ───────────────────────────────────

  Future<void> limparTudo() async {
    await _transacoesBox.clear();
    await _categoriasBox.clear();
    await _investimentosBox.clear();
    await _metasBox.clear();
    await _emprestimosBox.clear();
    await _inicializarCategoriasPadrao();
  }

  Future<void> fechar() async => Hive.close();
}