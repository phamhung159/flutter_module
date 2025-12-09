
import 'package:flutter_module/data/datasources/user_remote_datasource.dart';
import 'package:flutter_module/data/models/user_dto.dart';

import '../models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>?> fetchUsers();
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _userRemoteDataSource;

  UserRepositoryImpl(this._userRemoteDataSource);
  @override
  Future<List<UserModel>?> fetchUsers() async {
    try {
      final response = await _userRemoteDataSource.getUsers();
      final List<UserDTO>? data = response.data;
      return data?.map((json) => UserModel.fromDTO(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}