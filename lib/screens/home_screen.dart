import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/grafico_pizza.dart';
import '../theme/app_theme.dart';
import 'transaction_screen.dart';
import 'transactions_list_screen.dart';
import 'investment_screen.dart';
import 'goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: _abrirNovaTransacao,
        icon: const Icon(Icons.add),
        label: const Text('Nova movimentação'),
      )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _HomeTab(onVerTodas: () => setState(() => _currentIndex = 1));
      case 1:
        return const TransactionsListScreen();
      case 2:
        return const InvestmentScreen();
      case 3:
        return const GoalsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_outlined), activeIcon: Icon(Icons.swap_horiz), label: 'Transações'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up_outlined), activeIcon: Icon(Icons.trending_up), label: 'Investir'),
        BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), activeIcon: Icon(Icons.flag), label: 'Metas'),
      ],
    );
  }

  void _abrirNovaTransacao() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionScreen()));
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onVerTodas;
  const _HomeTab({required this.onVerTodas});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final ultimas = txProvider.transacoes.take(10).toList();

    final gastos = txProvider.gastosPorCategoria;
    final totalGastos = gastos.values.fold(0.0, (s, v) => s + v);
    final fatias = gastos.entries.map((e) {
      final cat = catProvider.buscarPorId(e.key);
      if (cat == null) return null;
      final index = catProvider.categorias.indexOf(cat);
      final cor = index >= 0 && index < AppTheme.categoryCores.length
          ? AppTheme.categoryCores[index]
          : AppTheme.categoryCores.last;
      return FatiaPizza(label: cat.nome, valor: e.value, cor: cor);
    }).whereType<FatiaPizza>().toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.bg,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_saudacao().toUpperCase(),
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    const Text('Kayo',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w600)),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.card2, shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('K', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Positioned(
                      top: 1, right: 1,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.green, shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bg, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: BalanceCard(
            saldo: txProvider.saldoTotal,
            receitas: txProvider.totalReceitas,
            despesas: txProvider.totalDespesas,
            deltaMes: txProvider.deltaMes,
          ),
        ),

        SliverToBoxAdapter(
          child: ResumoCards(
            receitas: txProvider.totalReceitas,
            despesas: txProvider.totalDespesas,
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gastos por categoria',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GraficoPizza(fatias: fatias, tamanho: 100),
                      const SizedBox(width: 20),
                      Expanded(child: LegendaPizza(fatias: fatias, total: totalGastos)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Movimentações recentes',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: onVerTodas,
                  style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary, padding: EdgeInsets.zero),
                  child: const Text('Ver todas', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),

        ultimas.isEmpty
            ? SliverToBoxAdapter(child: _EmptyState())
            : SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final tx = ultimas[index];
                final cat = catProvider.buscarPorId(tx.categoriaId);
                return Column(
                  children: [
                    TransactionTile(
                      transacao: tx,
                      categoria: cat,
                      onDelete: () => context.read<TransactionProvider>().removeTransaction(tx.id),
                    ),
                    if (index < ultimas.length - 1)
                      const Divider(height: 1, color: AppTheme.border),
                  ],
                );
              },
              childCount: ultimas.length,
            ),
          ),
        ),
      ],
    );
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia,';
    if (hora < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text('Nenhuma movimentação ainda',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
          Text('Toque em "Nova movimentação" para começar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}