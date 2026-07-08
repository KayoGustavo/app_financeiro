import 'package:flutter/material.dart';

enum CategoriaInvestimento { rendaFixa, rendaVariavel, outros }

class TipoInvestimento {
  final String id;
  final String nome;
  final String descricao;
  final double taxaMin;
  final double taxaMax;
  final double taxaSugerida; // taxa mensal decimal
  final bool temIR;
  final bool isento; // LCI/LCA são isentos
  final CategoriaInvestimento categoria;
  final IconData icone;
  final Color cor;
  final String exemploTexto;

  const TipoInvestimento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.taxaMin,
    required this.taxaMax,
    required this.taxaSugerida,
    required this.temIR,
    required this.isento,
    required this.categoria,
    required this.icone,
    required this.cor,
    required this.exemploTexto,
  });

  /// Taxa mínima em % ao mês
  double get taxaMinPercent => taxaMin * 100;

  /// Taxa máxima em % ao mês
  double get taxaMaxPercent => taxaMax * 100;

  /// Taxa sugerida em % ao mês
  double get taxaSugeridaPercent => taxaSugerida * 100;

  /// Label da categoria
  String get categoriaLabel {
    switch (categoria) {
      case CategoriaInvestimento.rendaFixa:
        return 'Renda Fixa';
      case CategoriaInvestimento.rendaVariavel:
        return 'Renda Variável';
      case CategoriaInvestimento.outros:
        return 'Outros';
    }
  }
}

class InvestmentTypes {
  InvestmentTypes._();

  static const TipoInvestimento tesouroCDB = TipoInvestimento(
    id: 'tesouro_cdb',
    nome: 'Tesouro Selic / CDB',
    descricao:
    'Títulos pós-fixados atrelados à Selic/CDI. Indicados para reserva de emergência. Seguros e com liquidez diária.',
    taxaMin: 0.009, // 0,9% ao mês
    taxaMax: 0.013, // 1,3% ao mês
    taxaSugerida: 0.011, // 1,1% ao mês (Selic ~14,25% a.a.)
    temIR: true,
    isento: false,
    categoria: CategoriaInvestimento.rendaFixa,
    icone: Icons.account_balance,
    cor: Color(0xFF2196F3),
    exemploTexto:
    'Com a Selic em 14,25% a.a., rende cerca de 1,1% ao mês. IR regressivo sobre o lucro.',
  );

  static const TipoInvestimento lciLca = TipoInvestimento(
    id: 'lci_lca',
    nome: 'LCI / LCA',
    descricao:
    'Letras de Crédito Imobiliário e do Agronegócio. Isentas de IR para pessoa física. Costumam pagar % do CDI.',
    taxaMin: 0.008, // 0,8% ao mês
    taxaMax: 0.012, // 1,2% ao mês
    taxaSugerida: 0.0099, // ~0,99% ao mês (90% CDI)
    temIR: false,
    isento: true,
    categoria: CategoriaInvestimento.rendaFixa,
    icone: Icons.shield_outlined,
    cor: Color(0xFF4CAF50),
    exemploTexto:
    'Isentas de IR. Costumam pagar 88% a 92% do CDI. Ótimas para médio prazo.',
  );

  static const TipoInvestimento poupanca = TipoInvestimento(
    id: 'poupanca',
    nome: 'Poupança',
    descricao:
    'Com Selic acima de 8,5% a.a., rende 0,5% ao mês + TR. Isenta de IR mas rende menos que as demais opções.',
    taxaMin: 0.005,
    taxaMax: 0.006,
    taxaSugerida: 0.005, // 0,5% ao mês
    temIR: false,
    isento: true,
    categoria: CategoriaInvestimento.rendaFixa,
    icone: Icons.savings_outlined,
    cor: Color(0xFF9C27B0),
    exemploTexto:
    'Rende 0,5% ao mês + TR quando a Selic está acima de 8,5% a.a. Isenta de IR.',
  );

  static const TipoInvestimento fiis = TipoInvestimento(
    id: 'fiis',
    nome: 'Fundos Imobiliários (FIIs)',
    descricao:
    'Cotas de grandes imóveis (shoppings, galpões, escritórios). Pagam dividendos mensais isentos de IR para pessoa física.',
    taxaMin: 0.007, // 0,7% ao mês
    taxaMax: 0.011, // 1,1% ao mês
    taxaSugerida: 0.009, // 0,9% ao mês
    temIR: false,
    isento: true,
    categoria: CategoriaInvestimento.rendaVariavel,
    icone: Icons.apartment_outlined,
    cor: Color(0xFFFF9800),
    exemploTexto:
    'Estimativa baseada em médias históricas. Dividendos mensais isentos de IR. Renda variável — pode oscilar.',
  );

  static const TipoInvestimento acoes = TipoInvestimento(
    id: 'acoes',
    nome: 'Ações (Bolsa)',
    descricao:
    'Frações de empresas negociadas na B3. Alto potencial de retorno no longo prazo, mas com maior volatilidade.',
    taxaMin: 0.008,
    taxaMax: 0.015,
    taxaSugerida: 0.011,
    temIR: true,
    isento: false,
    categoria: CategoriaInvestimento.rendaVariavel,
    icone: Icons.show_chart,
    cor: Color(0xFFE91E63),
    exemploTexto:
    'Simulação baseada em médias históricas de 10-15% a.a. Renda variável — resultado real pode variar.',
  );

  static const TipoInvestimento outros = TipoInvestimento(
    id: 'outros',
    nome: 'Outros / Taxa manual',
    descricao:
    'Informe a taxa manualmente. Use para CDBs específicos, debêntures, fundos ou qualquer outro investimento.',
    taxaMin: 0.001,
    taxaMax: 0.03,
    taxaSugerida: 0.01,
    temIR: true,
    isento: false,
    categoria: CategoriaInvestimento.outros,
    icone: Icons.tune,
    cor: Color(0xFF607D8B),
    exemploTexto: 'Informe a taxa de rendimento mensal do seu investimento.',
  );

  /// Lista completa de tipos
  static const List<TipoInvestimento> todos = [
    tesouroCDB,
    lciLca,
    poupanca,
    fiis,
    acoes,
    outros,
  ];

  /// Busca tipo por id
  static TipoInvestimento? porId(String id) {
    try {
      return todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}