import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final categorias = provider.categorias;

    // IDs das categorias padrão — não podem ser deletadas
    final idsPadrao = CategoryModel.categoriasPadrao.map((c) => c.id).toSet();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Categorias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Seção padrão
          const _SectionLabel(label: 'PADRÃO'),
          const SizedBox(height: 10),
          ...categorias
              .where((c) => idsPadrao.contains(c.id))
              .map((cat) => _CategoriaItem(
            categoria: cat,
            isPadrao: true,
          )),

          const SizedBox(height: 20),

          // Seção personalizadas
          const _SectionLabel(label: 'PERSONALIZADAS'),
          const SizedBox(height: 10),

          ...categorias
              .where((c) => !idsPadrao.contains(c.id))
              .map((cat) => _CategoriaItem(
            categoria: cat,
            isPadrao: false,
            onDelete: () =>
                context.read<CategoryProvider>().removeCategory(cat.id),
          )),

          if (categorias.where((c) => !idsPadrao.contains(c.id)).isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Nenhuma categoria personalizada ainda',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
    );
  }
}

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

class _CategoriaItem extends StatelessWidget {
  final CategoryModel categoria;
  final bool isPadrao;
  final VoidCallback? onDelete;

  const _CategoriaItem({
    required this.categoria,
    required this.isPadrao,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cor = _parseColor(categoria.cor);

    final item = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              IconData(categoria.iconeCodePoint,
                  fontFamily: categoria.iconeFontFamily),
              color: cor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              categoria.nome,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isPadrao)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.card2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Padrão',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10),
              ),
            ),
        ],
      ),
    );

    if (isPadrao) return item;

    return Dismissible(
      key: Key(categoria.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.redBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.card2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Deletar categoria',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            content: Text(
              'Tem certeza que deseja deletar "${categoria.nome}"? As transações dessa categoria não serão afetadas.',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Deletar',
                    style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: item,
    );
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}