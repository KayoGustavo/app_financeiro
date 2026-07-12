import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';
import '../theme/app_theme.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final metas = provider.metas;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: const Text(
                'Metas',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Resumo
          if (metas.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ResumoMini(
                        label: 'Metas ativas',
                        valor: '${provider.totalMetas}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResumoMini(
                        label: 'Concluídas',
                        valor: '${provider.metasConcluidas}',
                        cor: AppTheme.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResumoMini(
                        label: 'Progresso médio',
                        valor:
                        '${(provider.progressoMedio * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Lista ou empty
          metas.isEmpty
              ? SliverToBoxAdapter(child: _EmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final meta = metas[index];
                  return GoalCard(
                    meta: meta,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddGoalScreen(metaExistente: meta),
                      ),
                    ),
                    onDelete: () =>
                        context.read<GoalProvider>().removeGoal(meta.id),
                  );
                },
                childCount: metas.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova meta'),
      ),
    );
  }
}

class _ResumoMini extends StatelessWidget {
  final String label;
  final String valor;
  final Color? cor;

  const _ResumoMini({required this.label, required this.valor, this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              color: cor ?? AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: const [
          Icon(Icons.flag_outlined, size: 52, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text(
            'Nenhuma meta cadastrada',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Toque em "Nova meta" para começar a planejar',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}