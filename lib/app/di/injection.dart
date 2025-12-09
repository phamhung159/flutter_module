import 'package:flutter_module/app/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void setupServiceLocator(void Function() onLogout) {
  getIt.init();
}
