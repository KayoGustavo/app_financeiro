import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../theme/app_theme.dart';

class GoalCard extends StatelessWidget {
  final GoalModel meta;
  final VoidCallback? onDelete;

  const GoalCard({super.key, required this.meta, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cor = _parseColor(meta.cor);

    return Dismissible(
      key: Key(meta.id),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    IconData(meta.iconeCodePoint, fontFamily: 'MaterialIcons'),
                    color: cor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meta.nome,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (meta.concluida)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.greenBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Concluída',
                                style: TextStyle(
                                  color: AppTheme.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.diasRestantes != null
                            ? '${meta.diasRestantes} dias restantes'
                            : 'Sem prazo definido',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Barra de progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: meta.progresso,
                minHeight: 7,
                backgroundColor: AppTheme.card2,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
            const SizedBox(height: 8),

            // Valores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(meta.valorAtual)} de ${_fmt(meta.valorMeta)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(meta.progresso * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (!meta.concluida) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _abrirDialogoAdicionar(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar valor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cor,
                    side: BorderSide(color: cor.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _abrirDialogoAdicionar(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Adicionar valor',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: '0,00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final valor = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (valor != null && valor > 0) {
                context.read<GoalProvider>().adicionarValor(meta.id, valor);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Adicionar',
                style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}