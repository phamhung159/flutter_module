part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default([]) List<UserModel> listUsers,
    @Default(1) int currentPage,
  }) = _HomeState;
}