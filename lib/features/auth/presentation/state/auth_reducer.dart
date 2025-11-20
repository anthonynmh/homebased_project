import 'auth_state.dart';
import 'auth_actions.dart';

AppAuthState authReducer(AppAuthState state, dynamic action) {
  if (action is LoginRequestAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is LoginSuccessAction) {
    return state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      userId: action.userId,
      email: action.email,
    );
  }

  if (action is LoginFailureAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  if (action is LogoutAction) {
    return AppAuthState.initial();
  }

  return state;
}
