import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/loan_types.dart';
import '../models/loan_model.dart';
import '../providers/loan_provider.dart';
import '../services/loan_service.dart';
import '../widgets/termometro_taxa.dart';
import '../theme/app_theme.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _credorCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _taxaCtrl = TextEditingController();
  final _parcelasCtrl = TextEditingController();

  TipoEmprestimo? _tipoSelecionado;
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _credorCtrl.dispose();
    _valorCtrl.dispose();
    _taxaCtrl.dispose();
    _parcelasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxaAtual =
    double.tryParse(_taxaCtrl.text.replaceAll(',', '.'));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Novo empréstimo'),
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
            // Seletor de tipo
            const Text(
              'Tipo de empréstimo',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LoanTypes.todos.map((tipo) {
                final sel = _tipoSelecionado?.id == tipo.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _tipoSelecionado = tipo;
                    _taxaCtrl.text =
                        tipo.taxaSugeridaPercent.toStringAsFixed(2);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? tipo.cor.withOpacity(0.15)
                          : AppTheme.card2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? tipo.cor.withOpacity(0.4)
                            : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tipo.icone,
                            size: 14,
                            color: sel
                                ? tipo.cor
                                : AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          tipo.nome.split('/')[0].trim(),
                          style: TextStyle(
                            color: sel
                                ? tipo.cor
                                : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Alerta do tipo selecionado
            if (_tipoSelecionado != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.card2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Text(
                  _tipoSelecionado!.alerta,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Campos
            _Campo(ctrl: _descricaoCtrl, label: 'Descrição',
                hint: 'Ex: Financiamento do carro',
                capitalize: true),
            _Campo(ctrl: _credorCtrl, label: 'Credor',
                hint: 'Ex: Banco Itaú, Amigo João',
                capitalize: true),
            _Campo(ctrl: _valorCtrl, label: 'Valor emprestado',
                prefixText: 'R\$ ', isDecimal: true),
            _Campo(ctrl: _taxaCtrl, label: 'Taxa mensal',
                suffixText: '%', isDecimal: true),
            _Campo(ctrl: _parcelasCtrl, label: 'Número de parcelas',
                suffixText: 'x', isInt: true),
            const SizedBox(height: 4),

            // Termômetro
            if (taxaAtual != null && taxaAtual > 0) ...[
              TermometroTaxa(
                taxaMensal: taxaAtual / 100,
                isEmprestimo: true,
              ),
              const SizedBox(height: 12),
            ],

            // Preview em tempo real
            _PreviewEmprestimo(
              valorCtrl: _valorCtrl,
              taxaCtrl: _taxaCtrl,
              parcelasCtrl: _parcelasCtrl,
            ),
            const SizedBox(height: 24),

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
                    : const Text('Salvar empréstimo'),
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

    final emprestimo = LoanModel(
      id: const Uuid().v4(),
      descricao: _descricaoCtrl.text.trim(),
      tipoId: _tipoSelecionado?.id ?? 'outros',
      valorTotal: double.parse(_valorCtrl.text.replaceAll(',', '.')),
      taxaMensal:
      double.parse(_taxaCtrl.text.replaceAll(',', '.')) / 100,
      parcelas: int.parse(_parcelasCtrl.text),
      dataInicio: DateTime.now(),
      credor: _credorCtrl.text.trim(),
    );

    await context.read<LoanProvider>().addLoan(emprestimo);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Empréstimo registrado!'),
          backgroundColor: AppTheme.card2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ── Preview em tempo real ────────────────────────────────────────────────────

class _PreviewEmprestimo extends StatelessWidget {
  final TextEditingController valorCtrl;
  final TextEditingController taxaCtrl;
  final TextEditingController parcelasCtrl;

  const _PreviewEmprestimo({
    required this.valorCtrl,
    required this.taxaCtrl,
    required this.parcelasCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([valorCtrl, taxaCtrl, parcelasCtrl]),
      builder: (context, _) {
        final valor =
        double.tryParse(valorCtrl.text.replaceAll(',', '.'));
        final taxa =
        double.tryParse(taxaCtrl.text.replaceAll(',', '.'));
        final parcelas = int.tryParse(parcelasCtrl.text);

        if (valor == null || taxa == null || parcelas == null ||
            valor <= 0 || taxa <= 0 || parcelas <= 0) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Preencha valor, taxa e parcelas para ver a simulação',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          );
        }

        final taxaMensal = taxa / 100;
        final parcela = LoanService.calcularParcela(
          valorTotal: valor,
          taxaMensal: taxaMensal,
          parcelas: parcelas,
        );
        final totalPago = parcela * parcelas;
        final juros = totalPago - valor;
        final percentCusto = (juros / valor) * 100;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulação do empréstimo',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 12),
              _PRow(label: 'Valor da parcela',
                  valor: _fmt(parcela), destaque: true),
              const SizedBox(height: 8),
              _PRow(label: 'Total a pagar', valor: _fmt(totalPago)),
              const SizedBox(height: 8),
              _PRow(
                label: 'Total de juros',
                valor: '+${_fmt(juros)}',
                cor: AppTheme.red,
              ),
              const SizedBox(height: 8),
              _PRow(
                label: 'Você pagará',
                valor:
                '${percentCusto.toStringAsFixed(0)}% a mais que o emprestado',
                cor: percentCusto > 50 ? AppTheme.red : AppTheme.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

class _PRow extends StatelessWidget {
  final String label;
  final String valor;
  final Color? cor;
  final bool destaque;

  const _PRow(
      {required this.label,
        required this.valor,
        this.cor,
        this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        Text(valor,
            style: TextStyle(
              color: cor ?? AppTheme.textPrimary,
              fontSize: destaque ? 16 : 13,
              fontWeight:
              destaque ? FontWeight.w700 : FontWeight.w600,
            )),
      ],
    );
  }
}

// ── Campo reutilizável ────────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final String? prefixText;
  final String? suffixText;
  final bool isDecimal;
  final bool isInt;
  final bool capitalize;

  const _Campo({
    required this.ctrl,
    required this.label,
    this.hint,
    this.prefixText,
    this.suffixText,
    this.isDecimal = false,
    this.isInt = false,
    this.capitalize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          suffixText: suffixText,
        ),
        keyboardType: isInt
            ? TextInputType.number
            : isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization: capitalize
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        inputFormatters: isInt
            ? [FilteringTextInputFormatter.digitsOnly]
            : isDecimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))]
            : [],
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
          if (isInt) {
            if (int.tryParse(v) == null || int.parse(v) <= 0)
              return 'Valor inválido';
          } else if (isDecimal) {
            final p = double.tryParse(v.replaceAll(',', '.'));
            if (p == null || p <= 0) return 'Valor inválido';
          }
          return null;
        },
      ),
    );
  }
}