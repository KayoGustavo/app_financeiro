import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ClassificacaoTaxa { excelente, moderada, alta }

class TermometroTaxa extends StatelessWidget {
  /// Taxa mensal em decimal (ex: 0.011 = 1,1%)
  final double taxaMensal;

  /// Se true, classifica como taxa de EMPRÉSTIMO (lógica inversa)
  /// Se false, classifica como taxa de INVESTIMENTO
  final bool isEmprestimo;

  const TermometroTaxa({
    super.key,
    required this.taxaMensal,
    this.isEmprestimo = false,
  });

  @override
  Widget build(BuildContext context) {
    final classificacao = _classificar();
    final info = _info(classificacao);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEmprestimo ? 'Qualidade da taxa' : 'Rentabilidade',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: info.cor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  info.label,
                  style: TextStyle(
                    color: info.cor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra colorida em 3 faixas
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: 33,
                  child: Container(height: 8, color: const Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 33,
                  child: Container(height: 8, color: const Color(0xFFFFC107)),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 34,
                  child: Container(height: 8, color: const Color(0xFFF44336)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Labels das faixas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEmprestimo ? '< 2,5%' : '> 0,9%',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 9),
              ),
              Text(
                isEmprestimo ? '2,6% ~ 5%' : '0,5% ~ 0,9%',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 9),
              ),
              Text(
                isEmprestimo ? '> 5,5%' : '< 0,5%',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descrição
          Text(
            info.descricao,
            style: TextStyle(
              color: info.cor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ClassificacaoTaxa _classificar() {
    final taxaPercent = taxaMensal * 100;

    if (isEmprestimo) {
      if (taxaPercent <= 2.5) return ClassificacaoTaxa.excelente;
      if (taxaPercent <= 5.0) return ClassificacaoTaxa.moderada;
      return ClassificacaoTaxa.alta;
    } else {
      if (taxaPercent >= 0.9) return ClassificacaoTaxa.excelente;
      if (taxaPercent >= 0.5) return ClassificacaoTaxa.moderada;
      return ClassificacaoTaxa.alta;
    }
  }

  _Taxa _info(ClassificacaoTaxa c) {
    switch (c) {
      case ClassificacaoTaxa.excelente:
        return _Taxa(
          label: isEmprestimo ? 'Excelente' : 'Boa rentabilidade',
          cor: const Color(0xFF4CAF50),
          descricao: isEmprestimo
              ? 'Taxa no nível consignado ou com garantia. Ótima condição.'
              : 'Acima da média do mercado. Boa escolha.',
        );
      case ClassificacaoTaxa.moderada:
        return _Taxa(
          label: 'Moderada',
          cor: const Color(0xFFFFC107),
          descricao: isEmprestimo
              ? 'Taxa de fintech ou banco digital. Avalie outras opções.'
              : 'Rentabilidade razoável. Considere opções melhores.',
        );
      case ClassificacaoTaxa.alta:
        return _Taxa(
          label: isEmprestimo ? 'Alta — cuidado!' : 'Baixa rentabilidade',
          cor: const Color(0xFFF44336),
          descricao: isEmprestimo
              ? 'Taxa de crédito pessoal tradicional. Risco de endividamento.'
              : 'Abaixo da poupança. Reavalie o investimento.',
        );
    }
  }
}

class _Taxa {
  final String label;
  final Color cor;
  final String descricao;
  _Taxa({required this.label, required this.cor, required this.descricao});
}