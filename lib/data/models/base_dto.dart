import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_dto.freezed.dart';
part 'base_dto.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class BaseDTO<T> with _$BaseDTO<T> {
  factory BaseDTO({
    @JsonKey(name: 'code') required int code,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'data') T? data,
  }) = _BaseDTO<T>;

  factory BaseDTO.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseDTOFromJson<T>(json, fromJsonT);
}
