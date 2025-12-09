import 'package:flutter_module/data/models/base_dto.dart';
import 'package:flutter_module/data/models/user_dto.dart';
import 'package:injectable/injectable.dart';

import '../api/api_client.dart';

abstract class UserRemoteDataSource {
  Future<BaseDTO<List<UserDTO>>> getUsers({int page = 1, int pageSize = 10});
}

@Injectable(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BaseDTO<List<UserDTO>>> getUsers({int page = 1, int pageSize = 10}) async {
    return await apiClient.getUsers(page, pageSize);
  }
}