import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';
import '../services/investment_service.dart';
import '../widgets/investment_card.dart';
import '../theme/app_theme.dart';
import 'add_investment_screen.dart';

class MyInvestmentsScreen extends StatelessWidget {
  const MyInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentProvider>();
    final investimentos = provider.investimentos;

    // Gera a evolução mensal somando todos os investimentos
    final evolucao = _calcularEvolucaoTotal(provider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Meus Investimentos'),
        backgroundColor: AppTheme.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Card patrimônio
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patrimônio total',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fmt(provider.patrimonioTotal),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ResumoItem(
                            label: 'Total investido',
                            valor: _fmt(provider.totalInvestidoGeral),
                          ),
                        ),
                        Expanded(
                          child: _ResumoItem(
                            label: 'Lucro',
                            valor:
                            '${provider.lucroTotal >= 0 ? '+' : ''}${_fmt(provider.lucroTotal)}',
                            cor: provider.lucroTotal >= 0
                                ? AppTheme.green
                                : AppTheme.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Gráfico de linha
          if (evolucao.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evolução do patrimônio',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: _GraficoLinha(pontos: evolucao),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _labelsEixoX(evolucao.length),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Título lista
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: const Text(
                'Seus investimentos',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Lista ou empty
          investimentos.isEmpty
              ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 48, horizontal: 40),
              child: Column(
                children: [
                  const Icon(Icons.trending_up,
                      size: 52, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum investimento cadastrado',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toque em "Novo investimento" para começar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final inv = investimentos[index];
                  return InvestmentCard(
                    investimento: inv,
                    valorAtual: provider.patrimonioAtual(inv),
                    valorProjetado: provider.valorFinalProjetado(inv),
                    onDelete: () => context
                        .read<InvestmentProvider>()
                        .removeInvestment(inv.id),
                  );
                },
                childCount: investimentos.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInvestmentScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo investimento'),
      ),
    );
  }

  /// Soma a evolução mensal de todos os investimentos mês a mês
  List<double> _calcularEvolucaoTotal(InvestmentProvider provider) {
    if (provider.investimentos.isEmpty) return [];

    // Pega o maior prazo entre todos os investimentos
    final maxMeses = provider.investimentos
        .map((i) => i.tempoMeses)
        .reduce((a, b) => a > b ? a : b);

    final evolucao = List<double>.filled(maxMeses + 1, 0);

    for (final inv in provider.investimentos) {
      final e = InvestmentService.calcularEvolucaoMensal(
        valorInicial: inv.valorInicial,
        aporteMensal: inv.aporteMensal,
        taxaMensal: inv.taxaMensal,
        tempoMeses: inv.tempoMeses,
      );
      for (int i = 0; i < e.length; i++) {
        evolucao[i] += e[i];
      }
    }

    // Limita a 24 pontos para o gráfico não ficar poluído
    if (evolucao.length > 24) {
      final step = evolucao.length ~/ 24;
      return [
        for (int i = 0; i < evolucao.length; i += step) evolucao[i]
      ];
    }

    return evolucao;
  }

  List<Widget> _labelsEixoX(int totalPontos) {
    final labels = ['Início', '', '', '', 'Hoje'];
    return labels
        .map((l) => Text(l,
        style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 9)))
        .toList();
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

// ── Gráfico de linha com CustomPainter ───────────────────────────────────────

class _GraficoLinha extends StatelessWidget {
  final List<double> pontos;

  const _GraficoLinha({required this.pontos});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinhaPainter(pontos: pontos),
      size: Size.infinite,
    );
  }
}

class _LinhaPainter extends CustomPainter {
  final List<double> pontos;

  _LinhaPainter({required this.pontos});

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.length < 2) return;

    final minVal = pontos.reduce(min);
    final maxVal = pontos.reduce(max);
    final range = maxVal - minVal;

    // Normaliza o ponto para coordenadas do canvas
    Offset toOffset(int i, double v) {
      final x = i / (pontos.length - 1) * size.width;
      final y = range == 0
          ? size.height / 2
          : size.height - ((v - minVal) / range) * size.height * 0.85 - size.height * 0.05;
      return Offset(x, y);
    }

    final offsets = List.generate(pontos.length, (i) => toOffset(i, pontos[i]));

    // Área preenchida
    final pathArea = Path();
    pathArea.moveTo(offsets.first.dx, size.height);
    for (final o in offsets) {
      pathArea.lineTo(o.dx, o.dy);
    }
    pathArea.lineTo(offsets.last.dx, size.height);
    pathArea.close();

    final paintArea = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.green.withOpacity(0.3),
          AppTheme.green.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(pathArea, paintArea);

    // Linha
    final pathLinha = Path();
    pathLinha.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final cpX = (prev.dx + curr.dx) / 2;
      pathLinha.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    final paintLinha = Paint()
      ..color = AppTheme.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(pathLinha, paintLinha);

    // Ponto final
    canvas.drawCircle(
      offsets.last,
      4,
      Paint()..color = AppTheme.green,
    );
    canvas.drawCircle(
      offsets.last,
      4,
      Paint()
        ..color = AppTheme.card
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_LinhaPainter old) => old.pontos != pontos;
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _ResumoItem extends StatelessWidget {
  final String label;
  final String valor;
  final Color? cor;

  const _ResumoItem({required this.label, required this.valor, this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            color: cor ?? AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _fmt(double v) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);