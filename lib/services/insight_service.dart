import 'package:flutter/material.dart';
import '../models/insight_model.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/loan_model.dart';
import '../models/investment_model.dart';

class InsightService {
  InsightService._();

  /// Gera lista de insights com base nos dados do usuário.
  /// Retorna no máximo 8 insights priorizando alertas primeiro.
  static List<InsightModel> gerar({
    required List<TransactionModel> transacoes,
    required Map<String, double> gastosPorCategoria,
    required Map<String, String> nomesCategorias,
    required List<GoalModel> metas,
    required List<LoanModel> emprestimos,
    required List<InvestmentModel> investimentos,
    required double totalReceitas,
    required double totalDespesas,
    required double parcelaMensalTotal,
  }) {
    final insights = <InsightModel>[];

    // ── Alertas ───────────────────────────────────────

    // Despesas maiores que receitas
    if (totalDespesas > totalReceitas && totalReceitas > 0) {
      insights.add(InsightModel(
        titulo: 'Gastos acima da renda',
        descricao:
        'Suas despesas (${_pct(totalDespesas, totalReceitas)}% da renda) estão maiores que suas receitas este mês.',
        tipo: TipoInsight.alerta,
        icone: Icons.warning_amber_rounded,
        cor: const Color(0xFFF44336),
      ));
    }

    // Parcelas comprometendo mais de 30% da renda
    if (totalReceitas > 0 && parcelaMensalTotal > 0) {
      final pctParcelas = parcelaMensalTotal / totalReceitas * 100;
      if (pctParcelas > 30) {
        insights.add(InsightModel(
          titulo: 'Dívidas comprometendo a renda',
          descricao:
          'Suas parcelas mensais representam ${pctParcelas.toStringAsFixed(0)}% da sua renda. O recomendado é até 30%.',
          tipo: TipoInsight.alerta,
          icone: Icons.credit_card_off_outlined,
          cor: const Color(0xFFFF9800),
        ));
      }
    }

    // Empréstimo com taxa muito alta
    for (final emp in emprestimos.where((e) => !e.quitado)) {
      if (emp.taxaMensal > 0.05) {
        insights.add(InsightModel(
          titulo: 'Taxa alta em "${emp.descricao}"',
          descricao:
          '${emp.taxaMensalPercent.toStringAsFixed(1)}% ao mês. Considere negociar ou quitar antecipadamente.',
          tipo: TipoInsight.alerta,
          icone: Icons.trending_down,
          cor: const Color(0xFFF44336),
        ));
        break; // Só um alerta de taxa alta por vez
      }
    }

    // Investimento vencendo em menos de 3 meses
    for (final inv in investimentos) {
      final restante = inv.tempoMeses - inv.mesesDecorridos;
      if (restante > 0 && restante <= 3) {
        insights.add(InsightModel(
          titulo: '"${inv.nome}" vence em breve',
          descricao:
          'Seu investimento vence em $restante ${restante == 1 ? 'mês' : 'meses'}. Decida o que fazer com o valor.',
          tipo: TipoInsight.alerta,
          icone: Icons.timer_outlined,
          cor: const Color(0xFFFF9800),
        ));
        break;
      }
    }

    // ── Dicas ─────────────────────────────────────────

    // Maior categoria de gasto
    if (gastosPorCategoria.isNotEmpty) {
      final maiorEntry = gastosPorCategoria.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      final nomeCategoria =
          nomesCategorias[maiorEntry.key] ?? 'categoria';
      final pct = totalDespesas > 0
          ? (maiorEntry.value / totalDespesas * 100).toStringAsFixed(0)
          : '0';
      insights.add(InsightModel(
        titulo: 'Maior gasto: $nomeCategoria',
        descricao:
        '$nomeCategoria representa $pct% dos seus gastos este mês. Analise se há como reduzir.',
        tipo: TipoInsight.dica,
        icone: Icons.pie_chart_outline,
        cor: const Color(0xFF2196F3),
      ));
    }

    // Sem investimentos cadastrados
    if (investimentos.isEmpty && totalReceitas > 0) {
      insights.add(InsightModel(
        titulo: 'Comece a investir',
        descricao:
        'Você ainda não tem investimentos. Mesmo pequenos aportes mensais fazem grande diferença no longo prazo.',
        tipo: TipoInsight.dica,
        icone: Icons.savings_outlined,
        cor: const Color(0xFF2196F3),
      ));
    }

    // Sobra considerável sem destino
    final sobra = totalReceitas - totalDespesas - parcelaMensalTotal;
    if (sobra > totalReceitas * 0.2 && investimentos.isNotEmpty) {
      insights.add(InsightModel(
        titulo: 'Você tem sobra disponível',
        descricao:
        'Sobram aproximadamente ${_fmtSimples(sobra)} este mês. Considere aumentar seus aportes.',
        tipo: TipoInsight.dica,
        icone: Icons.lightbulb_outline,
        cor: const Color(0xFF2196F3),
      ));
    }

    // ── Conquistas ────────────────────────────────────

    // Mais receitas que despesas
    if (totalReceitas > totalDespesas && totalDespesas > 0) {
      final economia = totalReceitas - totalDespesas;
      insights.add(InsightModel(
        titulo: 'Mês positivo!',
        descricao:
        'Suas receitas superam suas despesas em ${_fmtSimples(economia)}. Continue assim!',
        tipo: TipoInsight.conquista,
        icone: Icons.thumb_up_outlined,
        cor: const Color(0xFF4CAF50),
      ));
    }

    // Meta próxima de concluir
    for (final meta in metas.where((m) => !m.concluida)) {
      if (meta.progresso >= 0.8) {
        insights.add(InsightModel(
          titulo: 'Quase lá: "${meta.nome}"',
          descricao:
          'Sua meta está ${(meta.progresso * 100).toStringAsFixed(0)}% concluída. Faltam apenas ${_fmtSimples(meta.faltante)}!',
          tipo: TipoInsight.conquista,
          icone: Icons.flag_outlined,
          cor: const Color(0xFF4CAF50),
        ));
        break;
      }
    }

    // Meta concluída
    for (final meta in metas.where((m) => m.concluida)) {
      insights.add(InsightModel(
        titulo: 'Meta atingida: "${meta.nome}"',
        descricao:
        'Parabéns! Você atingiu sua meta. Defina um novo objetivo para continuar evoluindo.',
        tipo: TipoInsight.conquista,
        icone: Icons.emoji_events_outlined,
        cor: const Color(0xFF4CAF50),
      ));
      break;
    }

    // Empréstimo quitado recentemente
    for (final emp in emprestimos.where((e) => e.quitado)) {
      insights.add(InsightModel(
        titulo: '"${emp.descricao}" quitado!',
        descricao:
        'Você quitou esse empréstimo. Use o valor da parcela (${_fmtSimples(emp.parcelaValor)}/mês) para investir agora.',
        tipo: TipoInsight.conquista,
        icone: Icons.check_circle_outline,
        cor: const Color(0xFF4CAF50),
      ));
      break;
    }

    // Prioriza alertas → dicas → conquistas, limita a 6
    insights.sort((a, b) => a.tipo.index.compareTo(b.tipo.index));
    return insights.take(6).toList();
  }

  static String _pct(double valor, double total) =>
      total > 0 ? (valor / total * 100).toStringAsFixed(0) : '0';

  static String _fmtSimples(double v) =>
      'R\$ ${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
      )}';
}