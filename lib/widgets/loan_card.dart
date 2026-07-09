import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/loan_types.dart';
import '../models/loan_model.dart';
import '../providers/loan_provider.dart';
import '../widgets/termometro_taxa.dart';
import '../theme/app_theme.dart';

class LoanCard extends StatelessWidget {
  final LoanModel emprestimo;
  final VoidCallback? onDelete;

  const LoanCard({super.key, required this.emprestimo, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tipo = LoanTypes.porId(emprestimo.tipoId);
    final cor = tipo?.cor ?? AppTheme.textSecondary;

    return Dismissible(
      key: Key(emprestimo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.redBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.red),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                    tipo?.icone ?? Icons.credit_card,
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
                              emprestimo.descricao,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (emprestimo.quitado)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.greenBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Quitado',
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
                        emprestimo.credor,
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
                value: emprestimo.progresso,
                minHeight: 7,
                backgroundColor: AppTheme.card2,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
            const SizedBox(height: 8),

            // Parcelas e valores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${emprestimo.parcelasPagas}/${emprestimo.parcelas} parcelas pagas',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(emprestimo.progresso * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'Parcela',
                    valor: _fmt(emprestimo.parcelaValor),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Saldo devedor',
                    valor: _fmt(emprestimo.saldoDevedor),
                    cor: AppTheme.red,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Taxa',
                    valor:
                    '${emprestimo.taxaMensalPercent.toStringAsFixed(1)}% a.m.',
                  ),
                ),
              ],
            ),

            // Termômetro e botão
            if (!emprestimo.quitado) ...[
              const SizedBox(height: 12),
              TermometroTaxa(
                taxaMensal: emprestimo.taxaMensal,
                isEmprestimo: true,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarPagamento(context),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Registrar parcela'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.green,
                    side: const BorderSide(color: AppTheme.green, width: 0.8),
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

  void _confirmarPagamento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Registrar pagamento',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: Text(
          'Confirma o pagamento da parcela ${emprestimo.parcelasPagas + 1}/${emprestimo.parcelas} de ${_fmt(emprestimo.parcelaValor)}?',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<LoanProvider>().registrarPagamento(emprestimo.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(
                  color: AppTheme.green, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

class _Stat extends StatelessWidget {
  final String label;
  final String valor;
  final Color? cor;

  const _Stat({required this.label, required this.valor, this.cor});

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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}