import 'package:flutter_module/data/datasources/user_remote_datasource.dart';
import 'package:flutter_module/data/models/user_dto.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';

abstract class HomeRepository {
  Future<List<UserModel>?> fetchUsers({int page = 1, int pageSize = 10});
}

@Injectable(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final UserRemoteDataSource _userRemoteDataSource;

  HomeRepositoryImpl(this._userRemoteDataSource);
  @override
  Future<List<UserModel>?> fetchUsers({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _userRemoteDataSource.getUsers(page: page, pageSize: pageSize);
      final List<UserDTO>? data = response.data;
      return data?.map((json) => UserModel.fromDTO(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}