class LoginRequestAction {
  final String email;
  final String password;
  LoginRequestAction(this.email, this.password);
}

class LoginSuccessAction {
  final String userId;
  final String email;
  LoginSuccessAction(this.userId, this.email);
}

class LoginFailureAction {
  final String error;
  LoginFailureAction(this.error);
}

class LogoutAction {}
