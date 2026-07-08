import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'my_investments_screen.dart';
import 'simulation_screen.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Investir',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              // Label seção
              const Text(
                'MEUS DADOS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Card — Meus Investimentos
              _HubCard(
                icone: Icons.trending_up,
                corIcone: AppTheme.green,
                bgIcone: AppTheme.greenBg,
                titulo: 'Meus Investimentos',
                subtitulo: 'Portfólio, evolução e gráfico',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyInvestmentsScreen()),
                ),
              ),
              const SizedBox(height: 20),

              // Label seção
              const Text(
                'FERRAMENTAS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Card — Simulações
              _HubCard(
                icone: Icons.calculate_outlined,
                corIcone: const Color(0xFF2196F3),
                bgIcone: const Color(0x262196F3),
                titulo: 'Simulações',
                subtitulo: 'Montante, meta, sobra e comparar',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SimulationScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final Color bgIcone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _HubCard({
    required this.icone,
    required this.corIcone,
    required this.bgIcone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgIcone,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icone, color: corIcone, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}