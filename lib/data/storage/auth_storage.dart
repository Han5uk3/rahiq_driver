import 'package:hive_flutter/hive_flutter.dart';

class AuthStorage {
  static const String _boxName = 'authBox';
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _box.put(_accessTokenKey, accessToken);
    await _box.put(_refreshTokenKey, refreshToken);
  }

  static String? getAccessToken() {
    return _box.get(_accessTokenKey);
  }

  static String? getRefreshToken() {
    return _box.get(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _box.delete(_accessTokenKey);
    await _box.delete(_refreshTokenKey);
  }

  static bool get isLoggedIn => getAccessToken() != null;
}
