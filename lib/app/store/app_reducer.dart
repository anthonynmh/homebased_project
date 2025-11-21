import 'app_state.dart';
import '../../features/auth/presentation/state/auth_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(auth: authReducer(state.auth, action));
}
