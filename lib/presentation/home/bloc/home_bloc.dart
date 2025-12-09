
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/repositories/home_repository/home_repository.dart';
import 'package:flutter_module/repositories/models/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';
part 'home_event.dart';
part 'home_bloc.freezed.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent,HomeState>{
  final HomeRepository _homeRepository;
  HomeBloc(this._homeRepository) : super(HomeState()){
    on<Initialized>(_onInitializedEvent);
    on<PullRefresh>(_onPullRefreshEvent);
    on<LoadMore>(_onLoadMoreEvent);
  }

  Future<void> _onInitializedEvent(Initialized event, Emitter<HomeState> emit) async {
    emit(const HomeState(isLoading: true));
    try {
      final users = await _homeRepository.fetchUsers(page: state.currentPage);
      emit(HomeState(isLoading: false, listUsers: users ?? []));
    } catch (e) {
      emit(const HomeState());
    }
  }

  Future<void> _onPullRefreshEvent(PullRefresh event, Emitter<HomeState> emit) async {
    emit(const HomeState(isLoading: true, currentPage: 1));
    try {
      final users = await _homeRepository.fetchUsers(page: state.currentPage);
      emit(HomeState(isLoading: false, listUsers: users ?? []));
    } catch (e) {
      emit(HomeState(isLoading: false, listUsers: []));
    }
  }

  Future<void> _onLoadMoreEvent(LoadMore event, Emitter<HomeState> emit) async {
    final nextPage = state.currentPage + 1;
    try {
      final users = await _homeRepository.fetchUsers(page: nextPage);
      final updatedList = List<UserModel>.from(state.listUsers)..addAll(users ?? []);
      emit(HomeState(isLoading: false, listUsers: updatedList, currentPage: nextPage));
    } catch (e) {
      emit(state.copyWith());
    }
  }
}