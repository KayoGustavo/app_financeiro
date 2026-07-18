import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/storage_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/investment_provider.dart';
import 'providers/simulation_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/loan_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await StorageService.init();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se já há sessão ativa
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: MaterialApp(
        title: 'FinançasPRO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        // Se já logado vai pra Home, senão vai pro Login
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}