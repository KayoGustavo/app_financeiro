import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Modelo de fatia ───────────────────────────────────────────────────────────

class FatiaPizza {
  final String label;
  final double valor;
  final Color cor;

  const FatiaPizza({
    required this.label,
    required this.valor,
    required this.cor,
  });
}

// ── Gráfico principal (donut) ─────────────────────────────────────────────────

class GraficoPizza extends StatelessWidget {
  final List<FatiaPizza> fatias;
  final double tamanho;

  const GraficoPizza({
    super.key,
    required this.fatias,
    this.tamanho = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Caso sem dados: exibe círculo cinza
    if (fatias.isEmpty) {
      return SizedBox(
        width: tamanho,
        height: tamanho,
        child: CustomPaint(
          painter: _DonutVazioPainter(),
          child: Center(
            child: Text(
              'Sem\ndespesas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ),
      );
    }

    final total = fatias.fold(0.0, (s, f) => s + f.valor);

    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(
        painter: _DonutPainter(fatias: fatias, total: total),
      ),
    );
  }
}

// ── Painter do donut preenchido ───────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<FatiaPizza> fatias;
  final double total;

  _DonutPainter({required this.fatias, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = size.width / 2;
    const espessura = 18.0;
    const gap = 0.03; // gap entre fatias em radianos

    final rect = Rect.fromCircle(center: centro, radius: raio - espessura / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.butt;

    double anguloAtual = -pi / 2; // começa do topo

    for (final fatia in fatias) {
      final proporcao = fatia.valor / total;
      final sweep = proporcao * 2 * pi - gap;

      paint.color = fatia.cor;
      canvas.drawArc(rect, anguloAtual, sweep, false, paint);
      anguloAtual += proporcao * 2 * pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.fatias != fatias || old.total != total;
}

// ── Painter do donut vazio ────────────────────────────────────────────────────

class _DonutVazioPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = size.width / 2;
    const espessura = 18.0;

    final rect = Rect.fromCircle(center: centro, radius: raio - espessura / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..color = AppTheme.card2;

    canvas.drawCircle(centro, raio - espessura / 2, paint);
    canvas.drawArc(rect, 0, 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(_DonutVazioPainter old) => false;
}

// ── Legenda ───────────────────────────────────────────────────────────────────

class LegendaPizza extends StatelessWidget {
  final List<FatiaPizza> fatias;
  final double total;

  const LegendaPizza({
    super.key,
    required this.fatias,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (fatias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: fatias.take(5).map((fatia) {
        final percent = total > 0 ? (fatia.valor / total * 100) : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: fatia.cor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  fatia.label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}