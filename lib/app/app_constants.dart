enum Environment {
  dev,
  staging,
  product,
}

extension EnvironmentExtension on Environment {
  String get name {
    switch (this) {
      case Environment.dev:
        return 'dev';
      case Environment.staging:
        return 'staging';
      case Environment.product:
        return 'product';
    }
  }
}

class AppConstants {
  static const String loginKey = 'Login_Key';
}