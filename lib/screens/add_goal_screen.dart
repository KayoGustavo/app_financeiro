import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../theme/app_theme.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();
  final _inicialCtrl = TextEditingController(text: '0');

  DateTime? _dataLimite;
  int _iconeSelecionado = 0;
  int _corSelecionada = 0;
  bool _salvando = false;

  static const _icones = [
    Icons.flight_takeoff,
    Icons.home_outlined,
    Icons.directions_car_outlined,
    Icons.school_outlined,
    Icons.celebration_outlined,
    Icons.savings_outlined,
    Icons.devices_outlined,
    Icons.favorite_outline,
  ];

  static const _cores = [
    '#4CAF50',
    '#2196F3',
    '#FF9800',
    '#9C27B0',
    '#E91E63',
    '#00BCD4',
    '#F44336',
    '#FFC107',
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _metaCtrl.dispose();
    _inicialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Nova meta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nome
            TextFormField(
              controller: _nomeCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nome da meta',
                hintText: 'Ex: Viagem para a praia',
                prefixIcon: Icon(Icons.flag_outlined, color: AppTheme.textSecondary),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 14),

            // Valor da meta
            TextFormField(
              controller: _metaCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Valor da meta',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.flag, color: AppTheme.textSecondary),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor da meta';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Valor inicial
            TextFormField(
              controller: _inicialCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Valor inicial (opcional)',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.savings_outlined, color: AppTheme.textSecondary),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p < 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Data limite
            GestureDetector(
              onTap: _selecionarData,
              child: AbsorbPointer(
                child: TextFormField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Data limite (opcional)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.textSecondary),
                    suffixIcon: _dataLimite != null
                        ? IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppTheme.textSecondary),
                      onPressed: () => setState(() => _dataLimite = null),
                    )
                        : null,
                  ),
                  controller: TextEditingController(
                    text: _dataLimite != null ? _formatarData(_dataLimite!) : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ícone
            const Text(
              'Ícone',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_icones.length, (i) {
                final selecionado = i == _iconeSelecionado;
                final cor = _parseColor(_cores[_corSelecionada]);
                return GestureDetector(
                  onTap: () => setState(() => _iconeSelecionado = i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selecionado ? cor.withOpacity(0.2) : AppTheme.card2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selecionado ? cor : AppTheme.border,
                        width: selecionado ? 1.5 : 0.5,
                      ),
                    ),
                    child: Icon(
                      _icones[i],
                      color: selecionado ? cor : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Cor
            const Text(
              'Cor',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_cores.length, (i) {
                final selecionado = i == _corSelecionada;
                final cor = _parseColor(_cores[i]);
                return GestureDetector(
                  onTap: () => setState(() => _corSelecionada = i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cor,
                      shape: BoxShape.circle,
                      border: selecionado
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Text('Criar meta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.green,
              onPrimary: Colors.white,
              surface: AppTheme.card2,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dataLimite = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final valorMeta = double.parse(_metaCtrl.text.replaceAll(',', '.'));
    final valorInicial = _inicialCtrl.text.trim().isEmpty
        ? 0.0
        : double.parse(_inicialCtrl.text.replaceAll(',', '.'));

    final meta = GoalModel(
      id: const Uuid().v4(),
      nome: _nomeCtrl.text.trim(),
      valorMeta: valorMeta,
      valorAtual: valorInicial,
      dataLimite: _dataLimite,
      iconeCodePoint: _icones[_iconeSelecionado].codePoint,
      cor: _cores[_corSelecionada],
    );

    await context.read<GoalProvider>().addGoal(meta);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meta criada!'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}