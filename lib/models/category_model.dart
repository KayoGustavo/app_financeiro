import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late int iconeCodePoint; // Código do ícone (ex: Icons.home.codePoint)

  @HiveField(3)
  late String iconeFontFamily; // Ex: 'MaterialIcons'

  @HiveField(4)
  late String cor; // Cor em hex, ex: '#FF5733'

  CategoryModel({
    required this.id,
    required this.nome,
    required this.iconeCodePoint,
    this.iconeFontFamily = 'MaterialIcons',
    this.cor = '#2196F3',
  });

  /// Categorias padrão que serão criadas na primeira execução do app
  static List<CategoryModel> get categoriasPadrao => [
    CategoryModel(
      id: 'cat_salario',
      nome: 'Salário',
      iconeCodePoint: 0xe227, // Icons.attach_money
      cor: '#4CAF50',
    ),
    CategoryModel(
      id: 'cat_alimentacao',
      nome: 'Alimentação',
      iconeCodePoint: 0xe533, // Icons.restaurant
      cor: '#FF9800',
    ),
    CategoryModel(
      id: 'cat_transporte',
      nome: 'Transporte',
      iconeCodePoint: 0xe531, // Icons.directions_car
      cor: '#2196F3',
    ),
    CategoryModel(
      id: 'cat_moradia',
      nome: 'Moradia',
      iconeCodePoint: 0xe318, // Icons.home
      cor: '#9C27B0',
    ),
    CategoryModel(
      id: 'cat_lazer',
      nome: 'Lazer',
      iconeCodePoint: 0xe40c, // Icons.sports_esports
      cor: '#E91E63',
    ),
    CategoryModel(
      id: 'cat_saude',
      nome: 'Saúde',
      iconeCodePoint: 0xe3f3, // Icons.local_hospital
      cor: '#F44336',
    ),
    CategoryModel(
      id: 'cat_investimentos',
      nome: 'Investimentos',
      iconeCodePoint: 0xe1cb, // Icons.trending_up
      cor: '#00BCD4',
    ),
    CategoryModel(
      id: 'cat_outros',
      nome: 'Outros',
      iconeCodePoint: 0xe145, // Icons.more_horiz
      cor: '#607D8B',
    ),
  ];
}