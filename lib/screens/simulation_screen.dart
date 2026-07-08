import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/investment_types.dart';
import '../models/simulation_result_model.dart';
import '../providers/simulation_provider.dart';
import '../services/investment_service.dart';
import '../widgets/termometro_taxa.dart';
import '../theme/app_theme.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      context.read<SimulationProvider>().limpar();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temNavAnterior = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: temNavAnterior
          ? AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Simulações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!temNavAnterior)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text(
                  'Simulações',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.textPrimary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 11),
                  tabs: const [
                    Tab(text: 'Montante'),
                    Tab(text: 'Meta'),
                    Tab(text: 'Sobra'),
                    Tab(text: 'Comparar'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _TabMontante(),
                  _TabMeta(),
                  _TabSobra(),
                  _TabComparar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aba 1: Montante ───────────────────────────────────────────────────────────

class _TabMontante extends StatefulWidget {
  const _TabMontante();

  @override
  State<_TabMontante> createState() => _TabMontanteState();
}

class _TabMontanteState extends State<_TabMontante> {
  final _valorCtrl = TextEditingController();
  final _aporteCtrl = TextEditingController();
  final _taxaCtrl = TextEditingController();
  final _prazoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TipoInvestimento? _tipoSelecionado;
  bool _temIR = true;
  bool _isento = false;

  @override
  void dispose() {
    _valorCtrl.dispose();
    _aporteCtrl.dispose();
    _taxaCtrl.dispose();
    _prazoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<SimulationProvider>().resultado;
    final taxaAtual = double.tryParse(_taxaCtrl.text.replaceAll(',', '.'));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Seletor de tipo
        _SeletorTipo(
          selecionado: _tipoSelecionado,
          onChanged: (tipo) {
            setState(() {
              _tipoSelecionado = tipo;
              _taxaCtrl.text =
                  tipo.taxaSugeridaPercent.toStringAsFixed(2);
              _temIR = tipo.temIR;
              _isento = tipo.isento;
            });
          },
        ),
        const SizedBox(height: 14),

        // Formulário
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _Campo(ctrl: _valorCtrl, label: 'Valor inicial', prefixText: 'R\$ '),
                _Campo(ctrl: _aporteCtrl, label: 'Aporte mensal', prefixText: 'R\$ '),
                _Campo(ctrl: _taxaCtrl, label: 'Taxa mensal', suffixText: '%'),
                _Campo(ctrl: _prazoCtrl, label: 'Prazo', suffixText: 'meses', soInteiroPositivo: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Termômetro
        if (taxaAtual != null && taxaAtual > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TermometroTaxa(taxaMensal: taxaAtual / 100),
          ),

        // IR badge
        if (_tipoSelecionado != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isento ? AppTheme.greenBg : AppTheme.redBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _isento ? Icons.check_circle_outline : Icons.info_outline,
                  color: _isento ? AppTheme.green : AppTheme.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isento
                      ? 'Isento de Imposto de Renda'
                      : 'Sujeito à tabela regressiva de IR',
                  style: TextStyle(
                    color: _isento ? AppTheme.green : AppTheme.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _calcular,
            child: const Text('Calcular'),
          ),
        ),

        if (resultado != null) ...[
          const SizedBox(height: 16),
          _GraficoDuasBarras(resultado: resultado),
          const SizedBox(height: 12),
          _ResultadoCard(resultado: resultado),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final valorInicial = _parseDouble(_valorCtrl.text);
    final aporteMensal = _parseDouble(_aporteCtrl.text);
    final taxaMensal = _parseDouble(_taxaCtrl.text) / 100;
    final prazoMeses = int.parse(_prazoCtrl.text);

    context.read<SimulationProvider>().simularMontanteComIR(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      prazoMeses: prazoMeses,
      temIR: _temIR,
      isento: _isento,
    );
  }
}

// ── Aba 2: Meta ───────────────────────────────────────────────────────────────

class _TabMeta extends StatefulWidget {
  const _TabMeta();

  @override
  State<_TabMeta> createState() => _TabMetaState();
}

class _TabMetaState extends State<_TabMeta> {
  final _metaCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _aporteCtrl = TextEditingController();
  final _taxaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _metaCtrl.dispose();
    _valorCtrl.dispose();
    _aporteCtrl.dispose();
    _taxaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<SimulationProvider>().resultado;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _Campo(ctrl: _metaCtrl, label: 'Meta financeira', prefixText: 'R\$ '),
                _Campo(ctrl: _valorCtrl, label: 'Valor inicial', prefixText: 'R\$ '),
                _Campo(ctrl: _aporteCtrl, label: 'Aporte mensal', prefixText: 'R\$ '),
                _Campo(ctrl: _taxaCtrl, label: 'Taxa mensal', suffixText: '%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _calcular,
            child: const Text('Calcular'),
          ),
        ),
        if (resultado != null) ...[
          const SizedBox(height: 16),
          _ResultadoCard(resultado: resultado, isMeta: true),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<SimulationProvider>().simularMeta(
      meta: _parseDouble(_metaCtrl.text),
      valorInicial: _parseDouble(_valorCtrl.text),
      aporteMensal: _parseDouble(_aporteCtrl.text),
      taxaMensal: _parseDouble(_taxaCtrl.text) / 100,
    );
  }
}

// ── Aba 3: Sobra ──────────────────────────────────────────────────────────────

class _TabSobra extends StatefulWidget {
  const _TabSobra();

  @override
  State<_TabSobra> createState() => _TabSobraState();
}

class _TabSobraState extends State<_TabSobra> {
  final _salarioCtrl = TextEditingController();
  final _gastoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController(text: '0');
  final _taxaCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _salarioCtrl.dispose();
    _gastoCtrl.dispose();
    _valorCtrl.dispose();
    _taxaCtrl.dispose();
    _metaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<SimulationProvider>().resultado;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _Campo(ctrl: _salarioCtrl, label: 'Salário mensal', prefixText: 'R\$ '),
                _Campo(ctrl: _gastoCtrl, label: 'Gasto mensal', prefixText: 'R\$ '),
                _Campo(ctrl: _valorCtrl, label: 'Valor inicial', prefixText: 'R\$ '),
                _Campo(ctrl: _taxaCtrl, label: 'Taxa mensal', suffixText: '%'),
                _Campo(ctrl: _metaCtrl, label: 'Meta financeira', prefixText: 'R\$ '),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        AnimatedBuilder(
          animation: Listenable.merge([_salarioCtrl, _gastoCtrl]),
          builder: (context, _) {
            final salario = double.tryParse(_salarioCtrl.text.replaceAll(',', '.'));
            final gasto = double.tryParse(_gastoCtrl.text.replaceAll(',', '.'));
            if (salario == null || gasto == null) return const SizedBox.shrink();
            final sobra = salario - gasto;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sobra > 0 ? AppTheme.greenBg : AppTheme.redBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    sobra > 0 ? Icons.check_circle_outline : Icons.warning_outlined,
                    color: sobra > 0 ? AppTheme.green : AppTheme.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sobra > 0
                        ? 'Sobra para investir: ${_fmt(sobra)}/mês'
                        : 'Gastos maiores que o salário!',
                    style: TextStyle(
                      color: sobra > 0 ? AppTheme.green : AppTheme.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _calcular,
            child: const Text('Calcular'),
          ),
        ),
        if (resultado != null) ...[
          const SizedBox(height: 16),
          _ResultadoCard(resultado: resultado, isMeta: true),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<SimulationProvider>().simularSobra(
      salario: _parseDouble(_salarioCtrl.text),
      gastoMensal: _parseDouble(_gastoCtrl.text),
      valorInicial: _parseDouble(_valorCtrl.text),
      taxaMensal: _parseDouble(_taxaCtrl.text) / 100,
      meta: _parseDouble(_metaCtrl.text),
    );
  }
}

// ── Aba 4: Comparador ─────────────────────────────────────────────────────────

class _TabComparar extends StatefulWidget {
  const _TabComparar();

  @override
  State<_TabComparar> createState() => _TabCompararState();
}

class _TabCompararState extends State<_TabComparar> {
  final _valorCtrl = TextEditingController();
  final _aporteCtrl = TextEditingController();
  final _prazoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<_ResultadoComparador> _resultados = [];

  @override
  void dispose() {
    _valorCtrl.dispose();
    _aporteCtrl.dispose();
    _prazoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compare o mesmo valor em todos os tipos',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 12),
                _Campo(ctrl: _valorCtrl, label: 'Valor inicial', prefixText: 'R\$ '),
                _Campo(ctrl: _aporteCtrl, label: 'Aporte mensal', prefixText: 'R\$ '),
                _Campo(ctrl: _prazoCtrl, label: 'Prazo', suffixText: 'meses', soInteiroPositivo: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _comparar,
            child: const Text('Comparar'),
          ),
        ),

        if (_resultados.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Resultado — do melhor ao pior',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._resultados.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return _CardComparador(resultado: r, posicao: i + 1);
          }),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  void _comparar() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final valor = _parseDouble(_valorCtrl.text);
    final aporte = _parseDouble(_aporteCtrl.text);
    final prazo = int.parse(_prazoCtrl.text);

    final resultados = InvestmentTypes.todos.map((tipo) {
      final resultado = InvestmentService.calcularComIR(
        valorInicial: valor,
        aporteMensal: aporte,
        taxaMensal: tipo.taxaSugerida,
        prazoMeses: prazo,
        temIR: tipo.temIR,
        isento: tipo.isento,
      );
      return _ResultadoComparador(tipo: tipo, resultado: resultado);
    }).toList();

    resultados.sort((a, b) =>
        b.resultado.montanteLiquido.compareTo(a.resultado.montanteLiquido));

    setState(() => _resultados = resultados);
  }
}

class _ResultadoComparador {
  final TipoInvestimento tipo;
  final SimulationResultModel resultado;
  _ResultadoComparador({required this.tipo, required this.resultado});
}

class _CardComparador extends StatelessWidget {
  final _ResultadoComparador resultado;
  final int posicao;

  const _CardComparador({required this.resultado, required this.posicao});

  @override
  Widget build(BuildContext context) {
    final isPrimeiro = posicao == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPrimeiro ? resultado.tipo.cor.withOpacity(0.1) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimeiro ? resultado.tipo.cor.withOpacity(0.3) : AppTheme.border,
          width: isPrimeiro ? 1 : 0.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: resultado.tipo.cor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$posicao',
              style: TextStyle(
                color: resultado.tipo.cor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(resultado.tipo.icone, color: resultado.tipo.cor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultado.tipo.nome,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  resultado.tipo.isento ? 'Isento de IR' : 'Com IR',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(resultado.resultado.montanteLiquido),
                style: TextStyle(
                  color: isPrimeiro ? resultado.tipo.cor : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '+${resultado.resultado.rentabilidadeLiquidaPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

// ── Gráfico de duas barras ────────────────────────────────────────────────────

class _GraficoDuasBarras extends StatelessWidget {
  final SimulationResultModel resultado;

  const _GraficoDuasBarras({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final investido = resultado.totalInvestido;
    final juros = resultado.lucro;
    final total = investido + juros;
    final propInvestido = total > 0 ? investido / total : 0.5;
    final propJuros = total > 0 ? juros / total : 0.5;
    final jurosUltrapassou = juros >= investido;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Composição do resultado',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              if (jurosUltrapassou)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.greenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚀 Juros > Investido!',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra empilhada
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: (propInvestido * 100).round(),
                  child: Container(
                    height: 20,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                ),
                Expanded(
                  flex: (propJuros * 100).round(),
                  child: Container(height: 20, color: AppTheme.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _BarLegenda(
                cor: AppTheme.textSecondary.withOpacity(0.3),
                label: 'Investido',
                valor: _fmt(investido),
              ),
              const SizedBox(width: 16),
              _BarLegenda(
                cor: AppTheme.green,
                label: 'Juros',
                valor: _fmt(juros),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

class _BarLegenda extends StatelessWidget {
  final Color cor;
  final String label;
  final String valor;

  const _BarLegenda(
      {required this.cor, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            Text(valor,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

// ── Seletor de tipo de investimento ──────────────────────────────────────────

class _SeletorTipo extends StatelessWidget {
  final TipoInvestimento? selecionado;
  final ValueChanged<TipoInvestimento> onChanged;

  const _SeletorTipo({required this.selecionado, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: InvestmentTypes.todos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tipo = InvestmentTypes.todos[i];
          final sel = selecionado?.id == tipo.id;
          return GestureDetector(
            onTap: () => onChanged(tipo),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: sel ? tipo.cor.withOpacity(0.15) : AppTheme.card2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? tipo.cor.withOpacity(0.4) : AppTheme.border,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(tipo.icone, size: 13, color: sel ? tipo.cor : AppTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    tipo.nome.split('/')[0].trim(),
                    style: TextStyle(
                      color: sel ? tipo.cor : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets reutilizáveis ─────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? prefixText;
  final String? suffixText;
  final bool soInteiroPositivo;

  const _Campo({
    required this.ctrl,
    required this.label,
    this.prefixText,
    this.suffixText,
    this.soInteiroPositivo = false,
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
          prefixText: prefixText,
          suffixText: suffixText,
        ),
        keyboardType: soInteiroPositivo
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          soInteiroPositivo
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
        ],
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
          if (soInteiroPositivo) {
            final p = int.tryParse(v);
            if (p == null || p <= 0) return 'Valor inválido';
          } else {
            final p = double.tryParse(v.replaceAll(',', '.'));
            if (p == null || p < 0) return 'Valor inválido';
          }
          return null;
        },
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final SimulationResultModel resultado;
  final bool isMeta;

  const _ResultadoCard({required this.resultado, this.isMeta = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 14),

          if (isMeta) ...[
            if (resultado.metaAtingida)
              _Row(label: 'Tempo para a meta', valor: resultado.tempoFormatado, destaque: true)
            else
              const _Row(label: 'Tempo para a meta', valor: 'Meta inatingível com esses valores', cor: AppTheme.red),
            const Divider(color: AppTheme.border, height: 20),
          ],

          _Row(label: 'Total investido', valor: _fmt(resultado.totalInvestido)),
          const SizedBox(height: 8),
          _Row(label: 'Montante bruto', valor: _fmt(resultado.montanteFinal)),

          if (resultado.temIR) ...[
            const SizedBox(height: 8),
            _Row(
              label: 'IR (${(resultado.aliquotaIR * 100).toStringAsFixed(1)}%)',
              valor: '-${_fmt(resultado.irDescontado)}',
              cor: AppTheme.red,
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'Montante líquido',
              valor: _fmt(resultado.montanteLiquido),
              destaque: true,
            ),
          ] else ...[
            const SizedBox(height: 8),
            _Row(label: 'Montante líquido', valor: _fmt(resultado.montanteLiquido), destaque: true),
          ],

          const SizedBox(height: 8),
          _Row(
            label: 'Lucro líquido',
            valor: '+${_fmt(resultado.lucroLiquido)}',
            cor: AppTheme.green,
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Rentabilidade líquida',
            valor: '${resultado.rentabilidadeLiquidaPercent.toStringAsFixed(1)}%',
            cor: AppTheme.green,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
}

class _Row extends StatelessWidget {
  final String label;
  final String valor;
  final Color? cor;
  final bool destaque;

  const _Row({required this.label, required this.valor, this.cor, this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(
          valor,
          style: TextStyle(
            color: cor ?? AppTheme.textPrimary,
            fontSize: destaque ? 16 : 13,
            fontWeight: destaque ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double _parseDouble(String text) =>
    double.tryParse(text.replaceAll(',', '.')) ?? 0.0;

String _fmt(double v) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);