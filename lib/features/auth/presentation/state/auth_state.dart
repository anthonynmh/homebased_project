class AppAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? error;

  AppAuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.userId,
    this.email,
    this.error,
  });

  factory AppAuthState.initial() {
    return AppAuthState(
      isLoading: false,
      isAuthenticated: false,
      userId: null,
      email: null,
      error: null,
    );
  }

  AppAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? error,
  }) {
    return AppAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }
}
