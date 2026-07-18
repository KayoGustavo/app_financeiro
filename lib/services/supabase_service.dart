import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de autenticação usando Supabase.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get usuarioAtual => _client.auth.currentUser;
  bool get estaLogado => usuarioAtual != null;

  /// Login com email e senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cadastro com email, senha e nome
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nome,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nome': nome},
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Envia email de redefinição de senha
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Escuta mudanças de autenticação (login/logout)
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}