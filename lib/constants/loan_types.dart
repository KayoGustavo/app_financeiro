import 'package:flutter/material.dart';

class TipoEmprestimo {
  final String id;
  final String nome;
  final String descricao;
  final double taxaMin;
  final double taxaMax;
  final double taxaSugerida;
  final int prazoMin;
  final int prazoMax;
  final IconData icone;
  final Color cor;
  final String alerta;

  const TipoEmprestimo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.taxaMin,
    required this.taxaMax,
    required this.taxaSugerida,
    required this.prazoMin,
    required this.prazoMax,
    required this.icone,
    required this.cor,
    required this.alerta,
  });

  double get taxaMinPercent => taxaMin * 100;
  double get taxaMaxPercent => taxaMax * 100;
  double get taxaSugeridaPercent => taxaSugerida * 100;
}

class LoanTypes {
  LoanTypes._();

  static const TipoEmprestimo consignadoPublico = TipoEmprestimo(
    id: 'consignado_publico',
    nome: 'Consignado Público / INSS',
    descricao: 'Desconto direto na folha ou aposentadoria. Taxa regulada pelo governo — menor do mercado.',
    taxaMin: 0.014,
    taxaMax: 0.0185,
    taxaSugerida: 0.017,
    prazoMin: 24,
    prazoMax: 84,
    icone: Icons.account_balance_outlined,
    cor: Color(0xFF4CAF50),
    alerta: 'Excelente taxa. Nível consignado — uma das melhores condições do mercado.',
  );

  static const TipoEmprestimo consignadoPrivado = TipoEmprestimo(
    id: 'consignado_privado',
    nome: 'Consignado Privado / FGTS',
    descricao: 'Voltado para CLT. Antecipa o Saque-Aniversário do FGTS descontado anualmente.',
    taxaMin: 0.016,
    taxaMax: 0.025,
    taxaSugerida: 0.02,
    prazoMin: 12,
    prazoMax: 120,
    icone: Icons.work_outline,
    cor: Color(0xFF2196F3),
    alerta: 'Boa taxa para CLT. Verifique o impacto no seu saldo do FGTS antes de contratar.',
  );

  static const TipoEmprestimo pessoal = TipoEmprestimo(
    id: 'pessoal',
    nome: 'Pessoal Tradicional',
    descricao: 'Crédito pessoal sem garantias. Bancos e fintechs. Taxa varia conforme o score.',
    taxaMin: 0.04,
    taxaMax: 0.085,
    taxaSugerida: 0.06,
    prazoMin: 12,
    prazoMax: 48,
    icone: Icons.person_outline,
    cor: Color(0xFFFF9800),
    alerta: 'Taxa alta! Você pode pagar mais que o dobro do valor emprestado. Avalie com cuidado.',
  );

  static const TipoEmprestimo garantia = TipoEmprestimo(
    id: 'garantia',
    nome: 'Com Garantia (Carro/Imóvel)',
    descricao: 'Veículo ou imóvel quitado como garantia. Taxa intermediária com prazos longos.',
    taxaMin: 0.011,
    taxaMax: 0.03,
    taxaSugerida: 0.02,
    prazoMin: 12,
    prazoMax: 240,
    icone: Icons.home_outlined,
    cor: Color(0xFF9C27B0),
    alerta: 'Taxa razoável. Atenção: o bem dado como garantia pode ser tomado em caso de inadimplência.',
  );

  static const TipoEmprestimo outros = TipoEmprestimo(
    id: 'outros',
    nome: 'Outros / Taxa manual',
    descricao: 'Informe a taxa manualmente para qualquer tipo de crédito.',
    taxaMin: 0.001,
    taxaMax: 0.15,
    taxaSugerida: 0.03,
    prazoMin: 1,
    prazoMax: 360,
    icone: Icons.tune,
    cor: Color(0xFF607D8B),
    alerta: 'Verifique a taxa no contrato antes de fechar.',
  );

  static const List<TipoEmprestimo> todos = [
    consignadoPublico,
    consignadoPrivado,
    pessoal,
    garantia,
    outros,
  ];

  static TipoEmprestimo? porId(String id) {
    try {
      return todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
