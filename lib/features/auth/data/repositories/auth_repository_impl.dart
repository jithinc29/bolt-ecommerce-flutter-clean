import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/auth_token.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/user_model.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_sqlite_clean/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<AuthToken> login(String email, String password) async {
    final tokenModel = await remoteDataSource.login(email, password);
    await saveToken(tokenModel);
    return tokenModel;
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    await secureStorage.write(key: _accessTokenKey, value: token.accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: token.refreshToken);
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessToken = await secureStorage.read(key: _accessTokenKey);
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return AuthToken(accessToken: accessToken, refreshToken: refreshToken);
    }
    return null;
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<UserModel> getProfile() async {
    final token = await getToken();
    if (token != null) {
      return await remoteDataSource.getProfile(token.accessToken);
    }
    throw Exception('No access token found');
  }
}
