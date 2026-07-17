import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Usuário atualmente logado
  User? get currentUser => _client.auth.currentUser;

  /// Cadastro
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Recupera a sessão atual
  Session? get session => _client.auth.currentSession;

  /// Verifica se há usuário logado
  bool get isLoggedIn => currentUser != null;
}