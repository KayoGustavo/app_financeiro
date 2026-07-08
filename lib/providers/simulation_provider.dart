import 'package:flutter/foundation.dart';
import '../models/simulation_result_model.dart';
import '../services/simulation_service.dart';
import '../services/investment_service.dart';

class SimulationProvider extends ChangeNotifier {
  SimulationResultModel? _resultado;
  SimulationResultModel? get resultado => _resultado;

  bool _carregando = false;
  bool get carregando => _carregando;

  /// Simulação 1: Montante simples (sem IR)
  void simularMontante({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int prazoMeses,
  }) {
    _carregando = true;
    notifyListeners();

    _resultado = SimulationService.simularMontante(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      prazoMeses: prazoMeses,
    );

    _carregando = false;
    notifyListeners();
  }

  /// Simulação 1 com IR: Montante com tabela regressiva de IR
  void simularMontanteComIR({
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
    required int prazoMeses,
    required bool temIR,
    required bool isento,
  }) {
    _carregando = true;
    notifyListeners();

    _resultado = InvestmentService.calcularComIR(
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
      prazoMeses: prazoMeses,
      temIR: temIR,
      isento: isento,
    );

    _carregando = false;
    notifyListeners();
  }

  /// Simulação 2: Tempo para atingir meta
  void simularMeta({
    required double meta,
    required double valorInicial,
    required double aporteMensal,
    required double taxaMensal,
  }) {
    _carregando = true;
    notifyListeners();

    _resultado = SimulationService.simularMeta(
      meta: meta,
      valorInicial: valorInicial,
      aporteMensal: aporteMensal,
      taxaMensal: taxaMensal,
    );

    _carregando = false;
    notifyListeners();
  }

  /// Simulação 3: Com base na sobra do salário
  void simularSobra({
    required double salario,
    required double gastoMensal,
    required double valorInicial,
    required double taxaMensal,
    required double meta,
  }) {
    _carregando = true;
    notifyListeners();

    _resultado = SimulationService.simularSobra(
      salario: salario,
      gastoMensal: gastoMensal,
      valorInicial: valorInicial,
      taxaMensal: taxaMensal,
      meta: meta,
    );

    _carregando = false;
    notifyListeners();
  }

  void limpar() {
    _resultado = null;
    notifyListeners();
  }
}