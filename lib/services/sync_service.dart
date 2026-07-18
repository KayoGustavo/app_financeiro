import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/investment_model.dart';
import '../models/goal_model.dart';
import '../models/loan_model.dart';
import 'storage_service.dart';

/// Serviço responsável por sincronizar os dados locais (Hive)
/// com o banco de dados remoto (Supabase).
///
/// Estratégia: Hive é a fonte de verdade local (funciona offline).
/// Supabase é o backup em nuvem (sincroniza quando há internet).
class SyncService {
  final SupabaseClient _client = Supabase.instance.client;
  final StorageService _storage = StorageService();

  String get _userId => _client.auth.currentUser!.id;

  // ── Upload: Hive → Supabase ──────────────────────────────────────────────

  /// Faz upload de todos os dados locais para o Supabase.
  /// Chamado após login ou quando o usuário pede sincronização manual.
  Future<void> uploadTudo() async {
    await Future.wait([
      _uploadTransacoes(),
      _uploadCategorias(),
      _uploadInvestimentos(),
      _uploadMetas(),
      _uploadEmprestimos(),
    ]);
  }

  Future<void> _uploadTransacoes() async {
    final transacoes = _storage.buscarTransacoes();
    if (transacoes.isEmpty) return;

    final dados = transacoes.map((t) => {
      'id': t.id,
      'user_id': _userId,
      'descricao': t.descricao,
      'valor': t.valor,
      'tipo': t.tipo == TipoTransacao.receita ? 'receita' : 'despesa',
      'categoria_id': t.categoriaId,
      'data': t.data.toIso8601String(),
      'observacao': t.observacao,
    }).toList();

    await _client.from('transacoes').upsert(dados);
  }

  Future<void> _uploadCategorias() async {
    final categorias = _storage.buscarCategorias();
    if (categorias.isEmpty) return;

    final dados = categorias.map((c) => {
      'id': c.id,
      'user_id': _userId,
      'nome': c.nome,
      'icone_code_point': c.iconeCodePoint,
      'icone_font_family': c.iconeFontFamily,
      'cor': c.cor,
    }).toList();

    await _client.from('categorias').upsert(dados);
  }

  Future<void> _uploadInvestimentos() async {
    final investimentos = _storage.buscarInvestimentos();
    if (investimentos.isEmpty) return;

    final dados = investimentos.map((i) => {
      'id': i.id,
      'user_id': _userId,
      'nome': i.nome,
      'valor_inicial': i.valorInicial,
      'aporte_mensal': i.aporteMensal,
      'taxa_mensal': i.taxaMensal,
      'tempo_meses': i.tempoMeses,
      'data_inicio': i.dataInicio.toIso8601String(),
      'descricao': i.descricao,
    }).toList();

    await _client.from('investimentos').upsert(dados);
  }

  Future<void> _uploadMetas() async {
    final metas = _storage.buscarMetas();
    if (metas.isEmpty) return;

    final dados = metas.map((m) => {
      'id': m.id,
      'user_id': _userId,
      'nome': m.nome,
      'valor_meta': m.valorMeta,
      'valor_atual': m.valorAtual,
      'data_limite': m.dataLimite?.toIso8601String(),
      'icone_code_point': m.iconeCodePoint,
      'cor': m.cor,
      'data_criacao': m.dataCriacao.toIso8601String(),
    }).toList();

    await _client.from('metas').upsert(dados);
  }

  Future<void> _uploadEmprestimos() async {
    final emprestimos = _storage.buscarEmprestimos();
    if (emprestimos.isEmpty) return;

    final dados = emprestimos.map((e) => {
      'id': e.id,
      'user_id': _userId,
      'descricao': e.descricao,
      'tipo_id': e.tipoId,
      'valor_total': e.valorTotal,
      'taxa_mensal': e.taxaMensal,
      'parcelas': e.parcelas,
      'parcelas_pagas': e.parcelasPagas,
      'data_inicio': e.dataInicio.toIso8601String(),
      'credor': e.credor,
    }).toList();

    await _client.from('emprestimos').upsert(dados);
  }

  // ── Download: Supabase → Hive ────────────────────────────────────────────

  /// Baixa todos os dados do Supabase e salva localmente no Hive.
  /// Chamado quando o usuário loga em um novo dispositivo.
  Future<void> downloadTudo() async {
    await Future.wait([
      _downloadTransacoes(),
      _downloadCategorias(),
      _downloadInvestimentos(),
      _downloadMetas(),
      _downloadEmprestimos(),
    ]);
  }

  Future<void> _downloadTransacoes() async {
    final rows = await _client
        .from('transacoes')
        .select()
        .eq('user_id', _userId);

    for (final row in rows) {
      final t = TransactionModel(
        id: row['id'],
        descricao: row['descricao'],
        valor: (row['valor'] as num).toDouble(),
        tipo: row['tipo'] == 'receita'
            ? TipoTransacao.receita
            : TipoTransacao.despesa,
        categoriaId: row['categoria_id'],
        data: DateTime.parse(row['data']),
        observacao: row['observacao'],
      );
      await _storage.salvarTransacao(t);
    }
  }

  Future<void> _downloadCategorias() async {
    final rows = await _client
        .from('categorias')
        .select()
        .eq('user_id', _userId);

    for (final row in rows) {
      final c = CategoryModel(
        id: row['id'],
        nome: row['nome'],
        iconeCodePoint: row['icone_code_point'],
        iconeFontFamily: row['icone_font_family'] ?? 'MaterialIcons',
        cor: row['cor'],
      );
      await _storage.salvarCategoria(c);
    }
  }

  Future<void> _downloadInvestimentos() async {
    final rows = await _client
        .from('investimentos')
        .select()
        .eq('user_id', _userId);

    for (final row in rows) {
      final i = InvestmentModel(
        id: row['id'],
        nome: row['nome'],
        valorInicial: (row['valor_inicial'] as num).toDouble(),
        aporteMensal: (row['aporte_mensal'] as num).toDouble(),
        taxaMensal: (row['taxa_mensal'] as num).toDouble(),
        tempoMeses: row['tempo_meses'],
        dataInicio: DateTime.parse(row['data_inicio']),
        descricao: row['descricao'],
      );
      await _storage.salvarInvestimento(i);
    }
  }

  Future<void> _downloadMetas() async {
    final rows = await _client
        .from('metas')
        .select()
        .eq('user_id', _userId);

    for (final row in rows) {
      final m = GoalModel(
        id: row['id'],
        nome: row['nome'],
        valorMeta: (row['valor_meta'] as num).toDouble(),
        valorAtual: (row['valor_atual'] as num).toDouble(),
        dataLimite: row['data_limite'] != null
            ? DateTime.parse(row['data_limite'])
            : null,
        iconeCodePoint: row['icone_code_point'],
        cor: row['cor'],
        dataCriacao: DateTime.parse(row['data_criacao']),
      );
      await _storage.salvarMeta(m);
    }
  }

  Future<void> _downloadEmprestimos() async {
    final rows = await _client
        .from('emprestimos')
        .select()
        .eq('user_id', _userId);

    for (final row in rows) {
      final e = LoanModel(
        id: row['id'],
        descricao: row['descricao'],
        tipoId: row['tipo_id'],
        valorTotal: (row['valor_total'] as num).toDouble(),
        taxaMensal: (row['taxa_mensal'] as num).toDouble(),
        parcelas: row['parcelas'],
        parcelasPagas: row['parcelas_pagas'] ?? 0,
        dataInicio: DateTime.parse(row['data_inicio']),
        credor: row['credor'],
      );
      await _storage.salvarEmprestimo(e);
    }
  }

  // ── Sincronização individual (chamada pelos providers) ───────────────────

  Future<void> sincronizarTransacao(TransactionModel t) async {
    try {
      await _client.from('transacoes').upsert({
        'id': t.id,
        'user_id': _userId,
        'descricao': t.descricao,
        'valor': t.valor,
        'tipo': t.tipo == TipoTransacao.receita ? 'receita' : 'despesa',
        'categoria_id': t.categoriaId,
        'data': t.data.toIso8601String(),
        'observacao': t.observacao,
      });
    } catch (_) {} // Falha silenciosa — Hive já salvou localmente
  }

  Future<void> deletarTransacao(String id) async {
    try {
      await _client.from('transacoes').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> sincronizarCategoria(CategoryModel c) async {
    try {
      await _client.from('categorias').upsert({
        'id': c.id,
        'user_id': _userId,
        'nome': c.nome,
        'icone_code_point': c.iconeCodePoint,
        'icone_font_family': c.iconeFontFamily,
        'cor': c.cor,
      });
    } catch (_) {}
  }

  Future<void> deletarCategoria(String id) async {
    try {
      await _client.from('categorias').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> sincronizarInvestimento(InvestmentModel i) async {
    try {
      await _client.from('investimentos').upsert({
        'id': i.id,
        'user_id': _userId,
        'nome': i.nome,
        'valor_inicial': i.valorInicial,
        'aporte_mensal': i.aporteMensal,
        'taxa_mensal': i.taxaMensal,
        'tempo_meses': i.tempoMeses,
        'data_inicio': i.dataInicio.toIso8601String(),
        'descricao': i.descricao,
      });
    } catch (_) {}
  }

  Future<void> deletarInvestimento(String id) async {
    try {
      await _client.from('investimentos').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> sincronizarMeta(GoalModel m) async {
    try {
      await _client.from('metas').upsert({
        'id': m.id,
        'user_id': _userId,
        'nome': m.nome,
        'valor_meta': m.valorMeta,
        'valor_atual': m.valorAtual,
        'data_limite': m.dataLimite?.toIso8601String(),
        'icone_code_point': m.iconeCodePoint,
        'cor': m.cor,
        'data_criacao': m.dataCriacao.toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> deletarMeta(String id) async {
    try {
      await _client.from('metas').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> sincronizarEmprestimo(LoanModel e) async {
    try {
      await _client.from('emprestimos').upsert({
        'id': e.id,
        'user_id': _userId,
        'descricao': e.descricao,
        'tipo_id': e.tipoId,
        'valor_total': e.valorTotal,
        'taxa_mensal': e.taxaMensal,
        'parcelas': e.parcelas,
        'parcelas_pagas': e.parcelasPagas,
        'data_inicio': e.dataInicio.toIso8601String(),
        'credor': e.credor,
      });
    } catch (_) {}
  }

  Future<void> deletarEmprestimo(String id) async {
    try {
      await _client.from('emprestimos').delete().eq('id', id);
    } catch (_) {}
  }
}