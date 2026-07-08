import 'package:hive/hive.dart';

part 'goal_model.g.dart';


@HiveType(typeId: 4)
class GoalModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late double valorMeta;

  @HiveField(3)
  late double valorAtual;

  @HiveField(4)
  DateTime? dataLimite;

  @HiveField(5)
  late int iconeCodePoint;

  @HiveField(6)
  late String cor; // hex, ex: '#4CAF50'

  @HiveField(7)
  late DateTime dataCriacao;

  GoalModel({
    required this.id,
    required this.nome,
    required this.valorMeta,
    this.valorAtual = 0,
    this.dataLimite,
    this.iconeCodePoint = 0xe1cb, // Icons.trending_up
    this.cor = '#4CAF50',
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  /// Progresso de 0.0 a 1.0
  double get progresso =>
      valorMeta > 0 ? (valorAtual / valorMeta).clamp(0.0, 1.0) : 0.0;

  /// Quanto falta para atingir a meta (nunca negativo)
  double get faltante => (valorMeta - valorAtual).clamp(0, double.infinity);

  /// Se a meta já foi atingida
  bool get concluida => valorAtual >= valorMeta;

  /// Dias restantes até a data limite (null se não houver data)
  int? get diasRestantes {
    if (dataLimite == null) return null;
    return dataLimite!.difference(DateTime.now()).inDays;
  }
}