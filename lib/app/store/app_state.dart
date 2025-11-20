import '../../features/auth/presentation/state/auth_state.dart';

class AppState {
  final AppAuthState auth;

  AppState({required this.auth});

  factory AppState.initial() {
    return AppState(auth: AppAuthState.initial());
  }

  AppState copyWith({AppAuthState? auth}) {
    return AppState(auth: auth ?? this.auth);
  }
}
