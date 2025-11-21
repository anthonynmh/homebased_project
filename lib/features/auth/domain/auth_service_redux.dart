import 'package:homebased_project/features/auth/data/auth_service.dart';

class AuthServiceRedux {
  final AuthService _service;

  AuthServiceRedux([AuthService? service]) : _service = service ?? authService;

  Future<void> signIn(String email, String password) async {
    await _service.signInWithEmailPassword(email: email, password: password);
    // Redux listener will handle LoginSuccessAction
  }

  Future<void> signUp(String email, String password) async {
    await _service.signUpWithEmailPassword(email: email, password: password);
    // Redux listener will handle LoginSuccessAction
  }

  Future<void> signOut() async {
    await _service.signOut();
    // Redux listener will handle LogoutAction
  }
}
