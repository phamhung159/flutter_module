import 'package:dio/dio.dart';
import 'package:flutter_module/data/models/user_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/base_dto.dart';
import 'api_constants.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "")
@lazySingleton
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(Dio dio) = _ApiClient;

  @POST(APIPath.users)
  Future<BaseDTO<List<UserDTO>>> getUsers(
    @Query('page') int page,
    @Query('pageSize') int pageSize,
  );
}