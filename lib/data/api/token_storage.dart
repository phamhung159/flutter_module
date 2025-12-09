import 'package:flutter_module/app/app_constants.dart';
import 'package:flutter_module/app/local_storage/shared_preference.dart';
import 'package:injectable/injectable.dart';

@factoryMethod
class TokenStorage {
  static const appToken = 'token';

  Future<void> save(String token) async {
    // TODO: Save token
    await SharedPreference.shared.save(AppConstants.loginKey, 'TOKEN');
  }

  Future<String?> getToken() async {
    // TODO: Get token
    return 'TOKEN';
  }

  Future<void> clear() async =>
      (await SharedPreference.shared.remove(appToken));
}
