import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/investment_model.dart';
import '../providers/investment_provider.dart';
import '../theme/app_theme.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _valorInicialCtrl = TextEditingController();
  final _aporteCtrl = TextEditingController(text: '0');
  final _taxaCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController();

  bool _salvando = false;

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
        title: const Text('Novo investimento'),
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
                labelText: 'Nome do investimento',
                hintText: 'Ex: Tesouro Selic',
                prefixIcon: Icon(Icons.label_outline, color: AppTheme.textSecondary),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 14),

            // Valor inicial
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor inicial';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Aporte mensal
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o aporte (ou 0)';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Taxa mensal
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a taxa';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Taxa inválida';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Prazo em meses
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o prazo';
                final parsed = int.tryParse(v);
                if (parsed == null || parsed <= 0) return 'Prazo inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Preview do resultado
            _PreviewCard(
              valorInicialCtrl: _valorInicialCtrl,
              aporteCtrl: _aporteCtrl,
              taxaCtrl: _taxaCtrl,
              tempoCtrl: _tempoCtrl,
            ),
            const SizedBox(height: 24),

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
                    : const Text('Salvar investimento'),
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

    final valorInicial = double.parse(_valorInicialCtrl.text.replaceAll(',', '.'));
    final aporte = double.parse(_aporteCtrl.text.replaceAll(',', '.'));
    final taxaPercent = double.parse(_taxaCtrl.text.replaceAll(',', '.'));
    final tempo = int.parse(_tempoCtrl.text);

    final investimento = InvestmentModel(
      id: const Uuid().v4(),
      nome: _nomeCtrl.text.trim(),
      valorInicial: valorInicial,
      aporteMensal: aporte,
      taxaMensal: taxaPercent / 100, // converte % para decimal
      tempoMeses: tempo,
      dataInicio: DateTime.now(),
    );

    await context.read<InvestmentProvider>().addInvestment(investimento);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Investimento adicionado!'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ── Preview em tempo real do resultado ──────────────────────────────────────

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
        final aporte = double.tryParse(aporteCtrl.text.replaceAll(',', '.')) ?? 0;
        final taxaPercent = double.tryParse(taxaCtrl.text.replaceAll(',', '.')) ?? 0;
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
              const Text(
                'Projeção ao final do prazo',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PreviewItem(
                      label: 'Investido',
                      valor: investido,
                    ),
                  ),
                  Expanded(
                    child: _PreviewItem(
                      label: 'Acumulado',
                      valor: montante,
                      destaque: true,
                    ),
                  ),
                  Expanded(
                    child: _PreviewItem(
                      label: 'Lucro',
                      valor: lucro,
                      cor: AppTheme.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final double valor;
  final Color? cor;
  final bool destaque;

  const _PreviewItem({
    required this.label,
    required this.valor,
    this.cor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatado = valor.toStringAsFixed(2).replaceAll('.', ',');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          'R\$ $formatado',
          style: TextStyle(
            color: cor ?? AppTheme.textPrimary,
            fontSize: destaque ? 14 : 12,
            fontWeight: destaque ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}