abstract class AuthService {
  Future<bool> login(String username, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Stream<bool> get authStateChanges;
}
