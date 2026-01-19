import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/auth_token.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/user_model.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_sqlite_clean/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_sqlite_clean/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/providers/product_providers.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthRemoteDataSourceImpl(client: client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isSplashDoneProvider = StateProvider<bool>((ref) => false);

class AuthState {
  final AuthToken? token;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    AuthToken? token,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState()) {
    checkToken();
  }

  Future<void> checkToken() async {
    final token = await repository.getToken();
    if (token != null) {
      state = state.copyWith(
        token: token,
        isInitialized: false,
      ); // Still initializing
      await fetchProfile();
      state = state.copyWith(isInitialized: true);
    } else {
      state = AuthState(isInitialized: true);
    }
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await repository.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = await repository.login(email, password);
      final user = await repository.getProfile();
      state = state.copyWith(token: token, user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await repository.clearToken();
    state = AuthState(isInitialized: true);
  }
}
