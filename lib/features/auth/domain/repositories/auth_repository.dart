import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/auth_token.dart';
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/user_model.dart';

abstract class AuthRepository {
  Future<AuthToken> login(String email, String password);
  Future<void> saveToken(AuthToken token);
  Future<AuthToken?> getToken();
  Future<void> clearToken();
  Future<UserModel> getProfile();
}
