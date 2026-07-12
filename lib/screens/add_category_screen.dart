import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../theme/app_theme.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();

  int _iconeSelecionado = 0;
  int _corSelecionada = 0;
  bool _salvando = false;

  static const _icones = [
    Icons.restaurant_outlined,
    Icons.directions_car_outlined,
    Icons.home_outlined,
    Icons.sports_esports_outlined,
    Icons.local_hospital_outlined,
    Icons.school_outlined,
    Icons.shopping_bag_outlined,
    Icons.fitness_center_outlined,
    Icons.flight_takeoff_outlined,
    Icons.pets_outlined,
    Icons.music_note_outlined,
    Icons.book_outlined,
    Icons.coffee_outlined,
    Icons.phone_android_outlined,
    Icons.work_outline,
    Icons.celebration_outlined,
  ];

  static const _cores = [
    '#4CAF50',
    '#2196F3',
    '#FF9800',
    '#9C27B0',
    '#E91E63',
    '#F44336',
    '#00BCD4',
    '#FFC107',
    '#607D8B',
    '#795548',
    '#3F51B5',
    '#009688',
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = _parseColor(_cores[_corSelecionada]);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Nova categoria'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview da categoria
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: corAtual.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _icones[_iconeSelecionado],
                      color: corAtual,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nomeCtrl.text.isEmpty ? 'Nome da categoria' : _nomeCtrl.text,
                    style: TextStyle(
                      color: _nomeCtrl.text.isEmpty
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nome
            TextFormField(
              controller: _nomeCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                prefixIcon: Icon(Icons.label_outline,
                    color: AppTheme.textSecondary),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 24),

            // Ícone
            const Text('Ícone',
                style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_icones.length, (i) {
                final sel = i == _iconeSelecionado;
                return GestureDetector(
                  onTap: () => setState(() => _iconeSelecionado = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sel
                          ? corAtual.withOpacity(0.2)
                          : AppTheme.card2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? corAtual.withOpacity(0.5)
                            : AppTheme.border,
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _icones[i],
                      color:
                      sel ? corAtual : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Cor
            const Text('Cor',
                style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_cores.length, (i) {
                final sel = i == _corSelecionada;
                final cor = _parseColor(_cores[i]);
                return GestureDetector(
                  onTap: () => setState(() => _corSelecionada = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cor,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: sel
                          ? [
                        BoxShadow(
                          color: cor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: sel
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
                    : const Text('Criar categoria'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final categoria = CategoryModel(
      id: const Uuid().v4(),
      nome: _nomeCtrl.text.trim(),
      iconeCodePoint: _icones[_iconeSelecionado].codePoint,
      iconeFontFamily: 'MaterialIcons',
      cor: _cores[_corSelecionada],
    );

    await context.read<CategoryProvider>().addCategory(categoria);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Categoria criada!'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}