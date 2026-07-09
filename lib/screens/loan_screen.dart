import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../widgets/loan_card.dart';
import '../theme/app_theme.dart';
import 'add_loan_screen.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanProvider>();
    final emprestimos = provider.emprestimos;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Empréstimos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Resumo
          if (emprestimos.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3A1A1A),
                        AppTheme.card,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total em dívidas',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(provider.totalDividas),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ResumoItem(
                              label: 'Parcela mensal total',
                              valor: _fmt(provider.parcelaMensalTotal),
                              cor: AppTheme.red,
                            ),
                          ),
                          Expanded(
                            child: _ResumoItem(
                              label: 'Total de juros',
                              valor: _fmt(provider.totalJurosFuturos),
                            ),
                          ),
                        ],
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
                'Seus empréstimos',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Lista ou empty
          emprestimos.isEmpty
              ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 60, horizontal: 40),
              child: Column(
                children: const [
                  Icon(Icons.credit_card_off_outlined,
                      size: 52, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum empréstimo cadastrado',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Toque em "Novo empréstimo" para registrar',
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
                  final emp = emprestimos[index];
                  return LoanCard(
                    emprestimo: emp,
                    onDelete: () =>
                        context.read<LoanProvider>().removeLoan(emp.id),
                  );
                },
                childCount: emprestimos.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddLoanScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo empréstimo'),
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

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
        Text(valor,
            style: TextStyle(
              color: cor ?? AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}