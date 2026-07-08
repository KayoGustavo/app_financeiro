import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/transaction_tile.dart';
import '../theme/app_theme.dart';
import 'transaction_screen.dart';

enum _Filtro { todas, receitas, despesas }

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final _buscaCtrl = TextEditingController();
  _Filtro _filtro = _Filtro.todas;

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();

    final lista = _aplicarFiltros(txProvider.transacoes);
    final grupos = _agruparPorMes(lista);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Transações',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Campo de busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _buscaCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Buscar movimentação...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FiltroChip(
                    label: 'Todas',
                    selecionado: _filtro == _Filtro.todas,
                    onTap: () => setState(() => _filtro = _Filtro.todas),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Receitas',
                    selecionado: _filtro == _Filtro.receitas,
                    cor: AppTheme.green,
                    onTap: () => setState(() => _filtro = _Filtro.receitas),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Despesas',
                    selecionado: _filtro == _Filtro.despesas,
                    cor: AppTheme.red,
                    onTap: () => setState(() => _filtro = _Filtro.despesas),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Resumo do filtro atual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${lista.length} ${lista.length == 1 ? 'movimentação' : 'movimentações'}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatCurrency(
                      lista.fold(0.0, (s, t) => s + t.valorComSinal),
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Lista agrupada por mês
            Expanded(
              child: lista.isEmpty
                  ? _EmptyState(temBusca: _buscaCtrl.text.isNotEmpty)
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupo = grupos[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 8),
                        child: Text(
                          grupo.titulo,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...grupo.transacoes.map((tx) {
                        final cat = catProvider.buscarPorId(tx.categoriaId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: TransactionTile(
                            transacao: tx,
                            categoria: cat,
                            onDelete: () => context
                                .read<TransactionProvider>()
                                .removeTransaction(tx.id),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova movimentação'),
      ),
    );
  }

  List<TransactionModel> _aplicarFiltros(List<TransactionModel> todas) {
    var lista = todas;

    if (_filtro == _Filtro.receitas) {
      lista = lista.where((t) => t.isReceita).toList();
    } else if (_filtro == _Filtro.despesas) {
      lista = lista.where((t) => t.isDespesa).toList();
    }

    final busca = _buscaCtrl.text.trim().toLowerCase();
    if (busca.isNotEmpty) {
      lista = lista
          .where((t) => t.descricao.toLowerCase().contains(busca))
          .toList();
    }

    return lista;
  }

  List<_GrupoMes> _agruparPorMes(List<TransactionModel> transacoes) {
    final mapa = <String, List<TransactionModel>>{};

    for (final tx in transacoes) {
      final chave = '${tx.data.year}-${tx.data.month.toString().padLeft(2, '0')}';
      mapa.putIfAbsent(chave, () => []).add(tx);
    }

    final chavesOrdenadas = mapa.keys.toList()..sort((a, b) => b.compareTo(a));

    return chavesOrdenadas.map((chave) {
      final partes = chave.split('-');
      final ano = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final data = DateTime(ano, mes);
      final agora = DateTime.now();

      String titulo;
      if (ano == agora.year && mes == agora.month) {
        titulo = 'ESTE MÊS';
      } else {
        titulo = DateFormat('MMMM yyyy', 'pt_BR').format(data).toUpperCase();
      }

      return _GrupoMes(titulo: titulo, transacoes: mapa[chave]!);
    }).toList();
  }

  String _formatCurrency(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

class _GrupoMes {
  final String titulo;
  final List<TransactionModel> transacoes;
  _GrupoMes({required this.titulo, required this.transacoes});
}

// ── Chip de filtro ───────────────────────────────────────────────────────────

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final Color? cor;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corAtiva = cor ?? AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? corAtiva.withOpacity(0.15) : AppTheme.card2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? corAtiva.withOpacity(0.4) : AppTheme.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selecionado ? corAtiva : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool temBusca;

  const _EmptyState({required this.temBusca});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              temBusca ? Icons.search_off : Icons.receipt_long_outlined,
              size: 52,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              temBusca
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhuma movimentação ainda',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              temBusca
                  ? 'Tente buscar por outro termo'
                  : 'Toque em "Nova movimentação" para começar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}