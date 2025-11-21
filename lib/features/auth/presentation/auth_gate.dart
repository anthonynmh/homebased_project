import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:homebased_project/app/store/app_state.dart';
import 'package:homebased_project/features/auth/presentation/state/auth_state.dart';
import 'package:homebased_project/mvp2/auth/auth_page.dart';
import 'package:homebased_project/views/widget_tree.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppAuthState>(
      converter: (store) => store.state.auth,
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return const AuthPage();
        } else {
          return const WidgetTree(); // your main app
        }
      },
    );
  }
}
