import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  final double saldo;
  final double receitas;
  final double despesas;
  final double deltaMes;

  const BalanceCard({
    super.key,
    required this.saldo,
    required this.receitas,
    required this.despesas,
    required this.deltaMes,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _saldoVisivel = true;

  @override
  Widget build(BuildContext context) {
    final deltaPositivo = widget.deltaMes >= 0;
    final deltaColor = deltaPositivo ? AppTheme.green : AppTheme.red;
    final deltaIcon = deltaPositivo ? '↑' : '↓';
    final deltaTexto =
        '$deltaIcon ${deltaPositivo ? '+' : ''}${_fmt(widget.deltaMes)} este mês';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + olho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo total',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _saldoVisivel = !_saldoVisivel),
                child: Icon(
                  _saldoVisivel
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Valor principal
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _saldoVisivel
                ? Text(
              _fmt(widget.saldo),
              key: const ValueKey('visivel'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            )
                : const Text(
              'R\$ ••••••',
              key: ValueKey('oculto'),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Delta do mês
          Text(
            deltaTexto,
            style: TextStyle(
              color: deltaColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

// ── Cards de Receita e Despesa ────────────────────────────────────────────────

class ResumoCards extends StatelessWidget {
  final double receitas;
  final double despesas;

  const ResumoCards({
    super.key,
    required this.receitas,
    required this.despesas,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _ResumoCard(label: 'Receitas', valor: receitas, isReceita: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ResumoCard(label: 'Despesas', valor: despesas, isReceita: false),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String label;
  final double valor;
  final bool isReceita;

  const _ResumoCard({
    required this.label,
    required this.valor,
    required this.isReceita,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = isReceita ? AppTheme.greenBg : AppTheme.redBg;
    final iconColor = isReceita ? AppTheme.green : AppTheme.red;
    final icon = isReceita ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$')
                .format(valor),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}