import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  // Por enquanto dados estáticos — depois vêm do Supabase
  final String nome;
  final String email;

  const ProfileScreen({
    super.key,
    this.nome = 'Kayo Gustavo',
    this.email = 'kayo@email.com',
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';
    final membroDesde = _formatarData(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + nome
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.greenBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.green, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nome,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Informações
          _SectionLabel(label: 'INFORMAÇÕES'),
          const SizedBox(height: 10),
          _InfoCard(
            itens: [
              _InfoItem(label: 'Nome', valor: nome),
              _InfoItem(label: 'Email', valor: email),
              _InfoItem(label: 'Membro desde', valor: membroDesde),
              _InfoItem(
                label: 'Sincronização',
                valor: 'Local (Hive)',
                corValor: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ações
          _SectionLabel(label: 'CONTA'),
          const SizedBox(height: 10),
          _ActionCard(
            itens: [
              _ActionItem(
                icone: Icons.person_outline,
                label: 'Editar perfil',
                onTap: () => _editarPerfil(context),
              ),
              _ActionItem(
                icone: Icons.lock_outline,
                label: 'Alterar senha',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Botão sair
          GestureDetector(
            onTap: () => _confirmarLogout(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.redBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.red.withOpacity(0.3), width: 0.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Sair da conta',
                style: TextStyle(
                  color: AppTheme.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editarPerfil(BuildContext context) {
    // TODO: implementar edição de perfil com Supabase
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card2,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
            child: const Text('Sair',
                style: TextStyle(
                    color: AppTheme.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${meses[data.month - 1]} ${data.year}';
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String valor;
  final Color? corValor;
  _InfoItem({required this.label, required this.valor, this.corValor});
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> itens;
  const _InfoCard({required this.itens});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: itens.asMap().entries.map((e) {
          final ultimo = e.key == itens.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: ultimo
                  ? null
                  : Border(
                  bottom: BorderSide(color: AppTheme.border, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value.label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                Text(
                  e.value.valor,
                  style: TextStyle(
                    color: e.value.corValor ?? AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icone;
  final String label;
  final VoidCallback onTap;
  _ActionItem({required this.icone, required this.label, required this.onTap});
}

class _ActionCard extends StatelessWidget {
  final List<_ActionItem> itens;
  const _ActionCard({required this.itens});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: itens.asMap().entries.map((e) {
          final ultimo = e.key == itens.length - 1;
          return GestureDetector(
            onTap: e.value.onTap,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                border: ultimo
                    ? null
                    : Border(
                    bottom:
                    BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(e.value.icone,
                      color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
