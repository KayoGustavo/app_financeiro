import 'package:flutter/material.dart';
import '../models/insight_model.dart';
import '../theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final InsightModel insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.cor.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + ícone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: insight.corBadge.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  insight.labelBadge,
                  style: TextStyle(
                    color: insight.corBadge,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: insight.cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(insight.icone, color: insight.cor, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Título
          Text(
            insight.titulo,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Descrição
          Expanded(
            child: Text(
              insight.descricao,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Linha colorida na base
          const SizedBox(height: 10),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: insight.cor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carrossel de insights ─────────────────────────────────────────────────────

class InsightsCarrossel extends StatefulWidget {
  final List<InsightModel> insights;

  const InsightsCarrossel({super.key, required this.insights});

  @override
  State<InsightsCarrossel> createState() => _InsightsCarrosselState();
}

class _InsightsCarrosselState extends State<InsightsCarrossel> {
  final _pageController = PageController(viewportFraction: 0.82);
  int _paginaAtual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título + indicador
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insights',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_paginaAtual + 1}/${widget.insights.length}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Carrossel
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.insights.length,
            onPageChanged: (i) => setState(() => _paginaAtual = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 5,
                  right: index == widget.insights.length - 1 ? 20 : 5,
                ),
                child: InsightCard(insight: widget.insights[index]),
              );
            },
          ),
        ),

        // Dots indicadores
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.insights.length, (i) {
            final ativo = i == _paginaAtual;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: ativo ? 16 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: ativo
                    ? widget.insights[_paginaAtual].cor
                    : AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}