# FinançasPRO

Aplicativo mobile de gerenciamento financeiro pessoal desenvolvido em Flutter como projeto de portfólio.

---

## Funcionalidades

### Home
- Saldo total com opção de ocultar
- Delta do mês (variação receitas menos despesas)
- Gráfico de pizza por categoria de gastos
- Carrossel de insights automáticos (alertas, dicas e conquistas)
- Acesso rápido a categorias e perfil

### Transações
- Registro de receitas e despesas
- Categorias personalizáveis com ícone e cor
- Busca por descrição e filtro por tipo
- Agrupamento por mês
- Edição e exclusão com swipe

### Investimentos
- Cálculo de juros compostos com aportes mensais
- Tabela regressiva de IR (Tesouro Selic, CDB)
- Gráfico de linha com evolução do patrimônio
- Tipos predefinidos com taxas reais do mercado brasileiro

### Simulações
- Montante — quanto acumulo em X meses
- Meta — quando atinjo R$ X
- Sobra — com salário menos gastos como aporte
- Comparador — rankeia todos os tipos de investimento lado a lado

### Metas
- Criação com ícone, cor e prazo
- Barra de progresso com acompanhamento
- Adição incremental de valores

### Empréstimos
- Cálculo pela Tabela Price
- Tipos predefinidos (Consignado, Pessoal, FGTS, Garantia)
- Termômetro visual de qualidade da taxa
- Registro de parcelas pagas

### Insights automáticos
Gerados dinamicamente com base nos dados do usuário:
- Alerta de gastos acima da renda
- Alerta de parcelas comprometendo mais de 30% da renda
- Maior categoria de gasto do mês
- Meta próxima de concluir
- Empréstimo quitado

### Autenticação
- Login e cadastro com email e senha via Supabase
- Sessão persistente entre aberturas do app
- Perfil do usuário com logout e redefinição de senha

---

## Arquitetura

```
lib/
├── config/          Credenciais Supabase
├── constants/       Tipos de investimento e empréstimo
├── models/          Entidades com Hive (TransactionModel, GoalModel...)
├── providers/       Gerenciamento de estado (ChangeNotifier)
├── screens/         Telas do app
├── services/        StorageService, SyncService, SupabaseService...
├── theme/           AppTheme com paleta escura
└── widgets/         Componentes reutilizáveis
```

Fluxo de dados:
```
Screens -> Providers -> Services -> Hive (local) + Supabase (nuvem)
```

Estratégia offline-first: o Hive funciona como cache local, o app funciona sem internet. O SyncService sincroniza com o Supabase em background a cada operação.

---

## Stack

| Tecnologia | Uso |
|-----------|-----|
| Flutter | Framework mobile |
| Dart | Linguagem |
| Provider | Gerenciamento de estado |
| Hive | Banco de dados local (NoSQL) |
| Supabase | Autenticação e banco na nuvem |
| CustomPainter | Gráficos nativos (pizza, linha, barras) |
| intl | Formatação de datas e moeda (pt_BR) |
| uuid | Geração de IDs únicos |

---

## Como rodar

Pré-requisitos:
- Flutter SDK >= 3.0.0
- Android Studio ou VS Code
- Dispositivo Android ou emulador

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/app_financeiro.git

# Entre na pasta
cd app_financeiro

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

O app usa Supabase para autenticação. Crie uma conta em supabase.com e configure suas credenciais em lib/config/supabase_config.dart.

---

## Padrões usados

- Offline-first: Hive como fonte de verdade local, Supabase como backup em nuvem
- Separação de responsabilidades: Models, Services, Providers e Screens em camadas independentes
- Sync silencioso: erros de sincronização não travam o usuário, pois os dados locais sempre estão disponíveis
- Row Level Security: cada usuário acessa apenas os próprios dados no Supabase

---

## Autor

Desenvolvido por Kayo Gustavo

GitHub: https://github.com/kayogustavoopment, and a full API reference.
