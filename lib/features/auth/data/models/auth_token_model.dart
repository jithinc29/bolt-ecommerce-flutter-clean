import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  AuthTokenModel({required super.accessToken, required super.refreshToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
