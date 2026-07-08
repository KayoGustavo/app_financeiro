import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';
import '../theme/app_theme.dart';

class InvestmentCard extends StatelessWidget {
  final InvestmentModel investimento;
  final double valorAtual;
  final double valorProjetado;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const InvestmentCard({
    super.key,
    required this.investimento,
    required this.valorAtual,
    required this.valorProjetado,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = investimento.progresso.clamp(0.0, 1.0);

    return Dismissible(
      key: Key(investimento.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.redBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.red),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investimento.nome,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(investimento.taxaMensalPercent).toStringAsFixed(2)}% ao mês • ${investimento.tempoMeses} meses',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.greenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.trending_up,
                      color: AppTheme.green,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progresso,
                  minHeight: 5,
                  backgroundColor: AppTheme.card2,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                ),
              ),
              const SizedBox(height: 10),

              // Estatísticas
              Row(
                children: [
                  _Stat(label: 'Atual', valor: _formatCompact(valorAtual)),
                  const SizedBox(width: 16),
                  _Stat(label: 'Projetado', valor: _formatCompact(valorProjetado)),
                  const Spacer(),
                  _Stat(
                    label: 'Progresso',
                    valor: '${investimento.mesesDecorridos}/${investimento.tempoMeses} meses',
                    alignEnd: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCompact(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String valor;
  final bool alignEnd;

  const _Stat({required this.label, required this.valor, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}