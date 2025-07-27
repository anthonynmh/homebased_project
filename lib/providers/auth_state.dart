import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  Auth0? _auth0;
  Credentials? _credentials;

  Auth0? get auth0 => _auth0;
  Credentials? get credentials => _credentials;

  void setAuth(Auth0 auth0, Credentials credentials) {
    _auth0 = auth0;
    _credentials = credentials;
    notifyListeners();
  }

  void clear() {
    _auth0 = null;
    _credentials = null;
    notifyListeners();
  }

  bool get isLoggedIn => _credentials != null;
}
