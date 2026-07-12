import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/investment_model.dart';
import '../providers/investment_provider.dart';
import '../theme/app_theme.dart';

class AddInvestmentScreen extends StatefulWidget {
  /// Se vier preenchido, abre em modo de edição
  final InvestmentModel? investimentoExistente;

  const AddInvestmentScreen({super.key, this.investimentoExistente});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _valorInicialCtrl;
  late final TextEditingController _aporteCtrl;
  late final TextEditingController _taxaCtrl;
  late final TextEditingController _tempoCtrl;

  bool _salvando = false;

  bool get _isEdicao => widget.investimentoExistente != null;

  @override
  void initState() {
    super.initState();
    final inv = widget.investimentoExistente;

    _nomeCtrl = TextEditingController(text: inv?.nome ?? '');
    _valorInicialCtrl = TextEditingController(
      text: inv != null
          ? inv.valorInicial.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _aporteCtrl = TextEditingController(
      text: inv != null
          ? inv.aporteMensal.toStringAsFixed(2).replaceAll('.', ',')
          : '0',
    );
    _taxaCtrl = TextEditingController(
      text: inv != null
          ? inv.taxaMensalPercent.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _tempoCtrl = TextEditingController(
      text: inv != null ? inv.tempoMeses.toString() : '',
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorInicialCtrl.dispose();
    _aporteCtrl.dispose();
    _taxaCtrl.dispose();
    _tempoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(_isEdicao ? 'Editar investimento' : 'Novo investimento'),
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
            TextFormField(
              controller: _nomeCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nome do investimento',
                hintText: 'Ex: Tesouro Selic',
                prefixIcon: Icon(Icons.label_outline, color: AppTheme.textSecondary),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _valorInicialCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Valor inicial',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                    color: AppTheme.textSecondary),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p < 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _aporteCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Aporte mensal',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.add_circle_outline,
                    color: AppTheme.textSecondary),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o aporte';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p < 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _taxaCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Taxa de rendimento mensal',
                suffixText: '% ao mês',
                prefixIcon: Icon(Icons.percent, color: AppTheme.textSecondary),
                helperText: 'Ex: 0,8 para Tesouro Selic',
                helperStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a taxa';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p <= 0) return 'Taxa inválida';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _tempoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Prazo',
                suffixText: 'meses',
                prefixIcon: Icon(Icons.calendar_month_outlined,
                    color: AppTheme.textSecondary),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o prazo';
                final p = int.tryParse(v);
                if (p == null || p <= 0) return 'Prazo inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Preview
            _PreviewCard(
              valorInicialCtrl: _valorInicialCtrl,
              aporteCtrl: _aporteCtrl,
              taxaCtrl: _taxaCtrl,
              tempoCtrl: _tempoCtrl,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
                    : Text(_isEdicao
                    ? 'Salvar alterações'
                    : 'Salvar investimento'),
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

    final investimento = InvestmentModel(
      id: widget.investimentoExistente?.id ?? const Uuid().v4(),
      nome: _nomeCtrl.text.trim(),
      valorInicial:
      double.parse(_valorInicialCtrl.text.replaceAll(',', '.')),
      aporteMensal: double.parse(_aporteCtrl.text.replaceAll(',', '.')),
      taxaMensal:
      double.parse(_taxaCtrl.text.replaceAll(',', '.')) / 100,
      tempoMeses: int.parse(_tempoCtrl.text),
      dataInicio: widget.investimentoExistente?.dataInicio ?? DateTime.now(),
    );

    final provider = context.read<InvestmentProvider>();

    if (_isEdicao) {
      await provider.updateInvestment(investimento);
    } else {
      await provider.addInvestment(investimento);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdicao ? 'Investimento atualizado!' : 'Investimento salvo!'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ── Preview em tempo real ─────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final TextEditingController valorInicialCtrl;
  final TextEditingController aporteCtrl;
  final TextEditingController taxaCtrl;
  final TextEditingController tempoCtrl;

  const _PreviewCard({
    required this.valorInicialCtrl,
    required this.aporteCtrl,
    required this.taxaCtrl,
    required this.tempoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [valorInicialCtrl, aporteCtrl, taxaCtrl, tempoCtrl]),
      builder: (context, _) {
        final valorInicial =
            double.tryParse(valorInicialCtrl.text.replaceAll(',', '.')) ?? 0;
        final aporte =
            double.tryParse(aporteCtrl.text.replaceAll(',', '.')) ?? 0;
        final taxaPercent =
            double.tryParse(taxaCtrl.text.replaceAll(',', '.')) ?? 0;
        final tempo = int.tryParse(tempoCtrl.text) ?? 0;

        if (taxaPercent <= 0 || tempo <= 0) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.card2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              'Preencha taxa e prazo para ver a projeção',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          );
        }

        final taxaMensal = taxaPercent / 100;
        double montante = valorInicial;
        for (int i = 0; i < tempo; i++) {
          montante = montante * (1 + taxaMensal) + aporte;
        }
        final investido = valorInicial + (aporte * tempo);
        final lucro = montante - investido;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.card2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Projeção ao final do prazo',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _Item(label: 'Investido', valor: investido)),
                  Expanded(
                      child: _Item(
                          label: 'Acumulado',
                          valor: montante,
                          destaque: true)),
                  Expanded(
                      child: _Item(
                          label: 'Lucro',
                          valor: lucro,
                          cor: AppTheme.green)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final double valor;
  final Color? cor;
  final bool destaque;

  const _Item(
      {required this.label,
        required this.valor,
        this.cor,
        this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          'R\$ ${valor.toStringAsFixed(0)}',
          style: TextStyle(
            color: cor ?? AppTheme.textPrimary,
            fontSize: destaque ? 14 : 12,
            fontWeight:
            destaque ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}