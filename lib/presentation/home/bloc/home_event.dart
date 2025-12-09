part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.initEvent() = Initialized;
  const factory HomeEvent.pullRefresh() = PullRefresh;
  const factory HomeEvent.loadMore() = LoadMore;
}
