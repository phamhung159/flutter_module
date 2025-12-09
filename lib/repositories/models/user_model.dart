import 'package:flutter_module/data/models/user_dto.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {

  factory UserModel({String? name}) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromDTO(UserDTO dto) {
    return UserModel(
      name: dto.name,
    );
  }
}

extension UserModelX on UserModel {
  UserDTO toDTO() {
    return UserDTO(name: name);
  }
}