import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transacao;
  final CategoryModel? categoria;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transacao,
    this.categoria,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isReceita = transacao.isReceita;
    final valorColor = isReceita ? AppTheme.receita : AppTheme.textPrimary;
    final valorPrefix = isReceita ? '+' : '-';

    return Dismissible(
      key: Key(transacao.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.redBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.red),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _getIconData(),
                  size: 19,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 13),

              // Descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transacao.descricao,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isReceita ? 'Receita' : categoria?.nome ?? 'Despesa'} • ${_formatData()}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Valor
              Text(
                '$valorPrefix${NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ).format(transacao.valor)}',
                style: TextStyle(
                  color: valorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    if (categoria == null) return Icons.attach_money;
    return IconData(
      categoria!.iconeCodePoint,
      fontFamily: categoria!.iconeFontFamily,
    );
  }

  String _formatData() {
    final agora = DateTime.now();
    final data = transacao.data;

    if (data.year == agora.year &&
        data.month == agora.month &&
        data.day == agora.day) return 'hoje';

    final ontem = agora.subtract(const Duration(days: 1));
    if (data.year == ontem.year &&
        data.month == ontem.month &&
        data.day == ontem.day) return 'ontem';

    return DateFormat('dd/MM', 'pt_BR').format(data);
  }
}