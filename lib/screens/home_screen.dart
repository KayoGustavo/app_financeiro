import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/loan_provider.dart';
import '../providers/investment_provider.dart';
import '../services/insight_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/grafico_pizza.dart';
import '../widgets/insight_card.dart';
import '../theme/app_theme.dart';
import 'transaction_screen.dart';
import 'transactions_list_screen.dart';
import 'investment_screen.dart';
import 'goals_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';

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
    final goalProvider = context.watch<GoalProvider>();
    final loanProvider = context.watch<LoanProvider>();
    final invProvider = context.watch<InvestmentProvider>();

    // Pega nome real do usuário logado
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final meta = user?.userMetadata;
    final nomeUsuario = meta?['nome'] as String? ??
        (email.isNotEmpty ? email.split('@')[0] : 'Olá');
    final inicialUsuario =
    nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U';

    final ultimas = txProvider.transacoes.take(10).toList();

    // Gráfico de pizza
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

    // Nomes de categorias para o InsightService
    final nomesCategorias = {
      for (final cat in catProvider.categorias) cat.id: cat.nome,
    };

    // Gera insights
    final insights = InsightService.gerar(
      transacoes: txProvider.transacoes,
      gastosPorCategoria: gastos,
      nomesCategorias: nomesCategorias,
      metas: goalProvider.metas,
      emprestimos: loanProvider.emprestimos,
      investimentos: invProvider.investimentos,
      totalReceitas: txProvider.totalReceitas,
      totalDespesas: txProvider.totalDespesas,
      parcelaMensalTotal: loanProvider.parcelaMensalTotal,
    );

    return CustomScrollView(
      slivers: [
        // Header
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
                    Text(
                      _saudacao().toUpperCase(),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(nomeUsuario,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w600)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _abrirMenuAvatar(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.card2, shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border, width: 0.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(inicialUsuario,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
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
                ),
              ],
            ),
          ),
        ),

        // BalanceCard
        SliverToBoxAdapter(
          child: BalanceCard(
            saldo: txProvider.saldoTotal,
            receitas: txProvider.totalReceitas,
            despesas: txProvider.totalDespesas,
            deltaMes: txProvider.deltaMes,
          ),
        ),

        // ResumoCards
        SliverToBoxAdapter(
          child: ResumoCards(
            receitas: txProvider.totalReceitas,
            despesas: txProvider.totalDespesas,
          ),
        ),

        // Insights — só aparece se houver dados
        if (insights.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: InsightsCarrossel(insights: insights),
            ),
          ),

        // Gráfico de pizza
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

        // Últimas movimentações
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

        // Lista
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionScreen(
                            transacaoExistente: tx,
                          ),
                        ),
                      ),
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

  void _abrirMenuAvatar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Configurações',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _MenuOpcao(
              icone: Icons.person_outline,
              label: 'Meu perfil',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _MenuOpcao(
              icone: Icons.category_outlined,
              label: 'Gerenciar categorias',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
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

class _MenuOpcao extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;

  const _MenuOpcao({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icone, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}