import 'package:redux/redux.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';
import 'app_reducer.dart';
import 'package:homebased_project/features/auth/presentation/state/auth_actions.dart';

Store<AppState> createStore() {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [],
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    final session = event.session;

    if (session != null) {
      store.dispatch(LoginSuccessAction(session.user.id, session.user.email!));
    } else {
      store.dispatch(LogoutAction());
    }
  });

  return store;
}
