import 'package:flutter/material.dart';

enum TipoInsight { alerta, dica, conquista }

class InsightModel {
  final String titulo;
  final String descricao;
  final TipoInsight tipo;
  final IconData icone;
  final Color cor;

  const InsightModel({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.icone,
    required this.cor,
  });

  /// Cor do badge baseada no tipo
  Color get corBadge {
    switch (tipo) {
      case TipoInsight.alerta:
        return const Color(0xFFF44336);
      case TipoInsight.dica:
        return const Color(0xFF2196F3);
      case TipoInsight.conquista:
        return const Color(0xFF4CAF50);
    }
  }

  /// Label do badge
  String get labelBadge {
    switch (tipo) {
      case TipoInsight.alerta:
        return 'Alerta';
      case TipoInsight.dica:
        return 'Dica';
      case TipoInsight.conquista:
        return 'Conquista';
    }
  }
}