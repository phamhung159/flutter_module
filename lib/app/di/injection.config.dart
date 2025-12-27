// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_module/data/api/api_client.dart' as _i242;
import 'package:flutter_module/data/api/dio_config.dart' as _i258;
import 'package:flutter_module/data/datasources/user_remote_datasource.dart'
    as _i94;
import 'package:flutter_module/data/services/callkit_service.dart' as _i431;
import 'package:flutter_module/data/services/tencent_call_service.dart'
    as _i1029;
import 'package:flutter_module/presentation/call/bloc/call_bloc.dart' as _i1037;
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart' as _i415;
import 'package:flutter_module/repositories/home_repository/home_repository.dart'
    as _i68;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.factory<_i361.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i431.CallKitService>(() => _i431.CallKitService());
    gh.lazySingleton<_i1029.TencentCallService>(
      () => _i1029.TencentCallService(),
    );
    gh.factory<_i1037.CallBloc>(
      () => _i1037.CallBloc(
        gh<_i431.CallKitService>(),
        gh<_i1029.TencentCallService>(),
      ),
    );
    gh.lazySingleton<_i242.ApiClient>(
      () => _i242.ApiClient.new(gh<_i361.Dio>()),
    );
    gh.factory<_i94.UserRemoteDataSource>(
      () => _i94.UserRemoteDataSourceImpl(apiClient: gh<_i242.ApiClient>()),
    );
    gh.factory<_i68.HomeRepository>(
      () => _i68.HomeRepositoryImpl(gh<_i94.UserRemoteDataSource>()),
    );
    gh.factory<_i415.HomeBloc>(() => _i415.HomeBloc(gh<_i68.HomeRepository>()));
    return this;
  }
}

class _$DioModule extends _i258.DioModule {}
