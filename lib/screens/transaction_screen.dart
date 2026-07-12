import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../theme/app_theme.dart';

class TransactionScreen extends StatefulWidget {
  /// Se vier preenchido, abre em modo de edição
  final TransactionModel? transacaoExistente;

  const TransactionScreen({super.key, this.transacaoExistente});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _valorCtrl;
  late final TextEditingController _obsCtrl;

  late TipoTransacao _tipo;
  late String? _categoriaId;
  late DateTime _data;
  bool _salvando = false;

  bool get _isEdicao => widget.transacaoExistente != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transacaoExistente;

    _descricaoCtrl = TextEditingController(text: tx?.descricao ?? '');
    _valorCtrl = TextEditingController(
      text: tx != null ? tx.valor.toStringAsFixed(2).replaceAll('.', ',') : '',
    );
    _obsCtrl = TextEditingController(text: tx?.observacao ?? '');
    _tipo = tx?.tipo ?? TipoTransacao.despesa;
    _categoriaId = tx?.categoriaId;
    _data = tx?.data ?? DateTime.now();
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoryProvider>().categorias;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(_isEdicao ? 'Editar movimentação' : 'Nova movimentação'),
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
            // Seletor tipo
            _TipoSelector(
              tipo: _tipo,
              onChanged: (t) => setState(() => _tipo = t),
            ),
            const SizedBox(height: 20),

            // Descrição
            TextFormField(
              controller: _descricaoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Descrição',
                prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe uma descrição' : null,
            ),
            const SizedBox(height: 14),

            // Valor
            TextFormField(
              controller: _valorCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.attach_money, color: AppTheme.textSecondary),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Categoria
            DropdownButtonFormField<String>(
              value: _categoriaId,
              dropdownColor: AppTheme.card2,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIcon: Icon(Icons.category_outlined, color: AppTheme.textSecondary),
              ),
              items: categorias.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(cat.iconeCodePoint, fontFamily: cat.iconeFontFamily),
                        size: 18, color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(cat.nome),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _categoriaId = v),
              validator: (v) => v == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 14),

            // Data
            GestureDetector(
              onTap: _selecionarData,
              child: AbsorbPointer(
                child: TextFormField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary),
                  ),
                  controller: TextEditingController(text: _formatarData(_data)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Observação
            TextFormField(
              controller: _obsCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                prefixIcon: Icon(Icons.notes_outlined, color: AppTheme.textSecondary),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
                    : Text(_isEdicao ? 'Salvar alterações' : 'Salvar movimentação'),
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
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.green,
            onPrimary: Colors.white,
            surface: AppTheme.card2,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final valor = double.parse(_valorCtrl.text.replaceAll(',', '.'));

    final transacao = TransactionModel(
      id: widget.transacaoExistente?.id ?? const Uuid().v4(),
      descricao: _descricaoCtrl.text.trim(),
      valor: valor,
      tipo: _tipo,
      categoriaId: _categoriaId!,
      data: _data,
      observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
    );

    final provider = context.read<TransactionProvider>();

    if (_isEdicao) {
      await provider.updateTransaction(transacao);
    } else {
      await provider.addTransaction(transacao);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdicao ? 'Movimentação atualizada!' : 'Movimentação salva!'),
          backgroundColor: _tipo == TipoTransacao.receita
              ? AppTheme.green
              : AppTheme.card2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatarData(DateTime data) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
}

// ── Seletor Receita / Despesa ─────────────────────────────────────────────────

class _TipoSelector extends StatelessWidget {
  final TipoTransacao tipo;
  final ValueChanged<TipoTransacao> onChanged;

  const _TipoSelector({required this.tipo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Opcao(
            label: 'Despesa',
            icon: Icons.arrow_downward,
            selecionado: tipo == TipoTransacao.despesa,
            cor: AppTheme.red,
            onTap: () => onChanged(TipoTransacao.despesa),
          ),
          _Opcao(
            label: 'Receita',
            icon: Icons.arrow_upward,
            selecionado: tipo == TipoTransacao.receita,
            cor: AppTheme.green,
            onTap: () => onChanged(TipoTransacao.receita),
          ),
        ],
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selecionado;
  final Color cor;
  final VoidCallback onTap;

  const _Opcao({
    required this.label,
    required this.icon,
    required this.selecionado,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selecionado ? AppTheme.card : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selecionado
                ? Border.all(color: AppTheme.border, width: 0.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17,
                  color: selecionado ? cor : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                  color: selecionado ? cor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}