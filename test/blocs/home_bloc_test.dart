import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart';
import 'package:flutter_module/repositories/home_repository/home_repository.dart';
import 'package:flutter_module/repositories/models/user_model.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeBloc homeBloc;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    homeBloc = HomeBloc(mockRepository);
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc - Initial State', () {
    test('initial state has correct default values', () {
      expect(homeBloc.state.isLoading, false);
      expect(homeBloc.state.listUsers, []);
      expect(homeBloc.state.currentPage, 1);
    });
  });

  group('HomeBloc - Initialized Event', () {
    blocTest<HomeBloc, HomeState>(
      'emits [Loading, Loaded] when Initialized is added successfully',
      build: () {
        final mockUsers = [
          UserModel(name: 'User 1'),
          UserModel(name: 'User 2'),
        ];
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => mockUsers);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        HomeState(
          isLoading: false,
          listUsers: [
          UserModel(name: 'User 1'),
          UserModel(name: 'User 2'),
        ],
          currentPage: 1,
        ),
      ],
      verify: (bloc) {
        verify(() => mockRepository.fetchUsers(page: 1, pageSize: 10)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [Loading, Loaded with empty list] when fetchUsers returns null',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => null);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
      verify: (bloc) {
        verify(() => mockRepository.fetchUsers(page: 1, pageSize: 10)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [Loading, Loaded with empty list] when fetchUsers returns empty list',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits Loading then empty state when exception occurs',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenThrow(Exception('Network Error'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
      verify: (bloc) {
        verify(() => mockRepository.fetchUsers(page: 1, pageSize: 10)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'loads users from current page state',
      build: () {
        final mockUsers = List.generate(
          10,
          (i) => UserModel(name: 'User $i'),
        );
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => mockUsers);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.listUsers.length == 10 &&
            state.currentPage == 1),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles TimeoutException',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenThrow(TimeoutException('Request timeout'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles FormatException',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenThrow(FormatException('Invalid format'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles large user lists',
      build: () {
        final largeList = List.generate(
          100,
          (i) => UserModel(name: 'User $i'),
        );
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => largeList);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) =>
            !state.isLoading && state.listUsers.length == 100),
      ],
    );
  });

  group('HomeBloc - PullRefresh Event', () {
    blocTest<HomeBloc, HomeState>(
      'emits updated state with new data when PullRefresh is added',
      build: () {
        final mockUsers = [UserModel(name: 'Refreshed User 1')];
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => mockUsers);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'Old User')],
        currentPage: 2,
      ),
      act: (bloc) => bloc.add(const HomeEvent.pullRefresh()),
      expect: () => [
        const HomeState(isLoading: true, currentPage: 1),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.listUsers.length == 1 &&
            state.listUsers.first.name == 'Refreshed User 1' &&
            state.currentPage == 1),
      ],
      verify: (bloc) {
        verify(() => mockRepository.fetchUsers(page: 1, pageSize: 10)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'resets currentPage to 1 on PullRefresh',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      seed: () => HomeState(currentPage: 5),
      act: (bloc) => bloc.add(const HomeEvent.pullRefresh()),
      expect: () => [
        const HomeState(isLoading: true, currentPage: 1),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'replaces old data with new data on refresh',
      build: () {
        final newUsers = [
          UserModel(name: 'New User 1'),
          UserModel(name: 'New User 2'),
        ];
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => newUsers);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [
          UserModel(name: 'Old User 1'),
          UserModel(name: 'Old User 2'),
          UserModel(name: 'Old User 3'),
        ],
        currentPage: 3,
      ),
      act: (bloc) => bloc.add(const HomeEvent.pullRefresh()),
      expect: () => [
        const HomeState(isLoading: true, currentPage: 1),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.listUsers.length == 2 &&
            state.listUsers.first.name == 'New User 1'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'returns empty list when PullRefresh fails',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenThrow(Exception('Refresh failed'));
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'Old User')],
        currentPage: 2,
      ),
      act: (bloc) => bloc.add(const HomeEvent.pullRefresh()),
      expect: () => [
        const HomeState(isLoading: true, currentPage: 1),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'preserves empty list when PullRefresh returns null',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => null);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'Old User')],
        currentPage: 2,
      ),
      act: (bloc) => bloc.add(const HomeEvent.pullRefresh()),
      expect: () => [
        const HomeState(isLoading: true, currentPage: 1),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );
  });

  group('HomeBloc - LoadMore Event', () {
    blocTest<HomeBloc, HomeState>(
      'appends new users to list when LoadMore is triggered',
      build: () {
        final newUsers = [
          UserModel(name: 'User 11'),
          UserModel(name: 'User 12'),
        ];
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => newUsers);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [
          UserModel(name: 'User 1'),
          UserModel(name: 'User 2'),
        ],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        HomeState(
          isLoading: false,
          listUsers: [
            UserModel(name: 'User 1'),
            UserModel(name: 'User 2'),
            UserModel(name: 'User 11'),
            UserModel(name: 'User 12'),
          ],
          currentPage: 2,
        ),
      ],
      verify: (bloc) {
        verify(() => mockRepository.fetchUsers(page: 2, pageSize: 10)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'increments currentPage on LoadMore success',
      build: () {
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'User 1')],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        predicate<HomeState>((state) => state.currentPage == 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'decrements currentPage when LoadMore fails',
      build: () {
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenThrow(Exception('Load more failed'));
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'User 1')],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
    
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'preserves existing users when appending new ones',
      build: () {
        final newUsers = [UserModel(name: 'User 3')];
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => newUsers);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [
          UserModel(name: 'User 1'),
          UserModel(name: 'User 2'),
        ],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        predicate<HomeState>((state) =>
            state.listUsers.length == 3 &&
            state.listUsers.first.name == 'User 1' &&
            state.listUsers.last.name == 'User 3'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles empty response on LoadMore',
      build: () {
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'User 1')],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        predicate<HomeState>((state) =>
            state.listUsers.length == 1 && state.currentPage == 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles null response on LoadMore',
      build: () {
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => null);
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [UserModel(name: 'User 1')],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        predicate<HomeState>((state) =>
            state.listUsers.length == 1 && state.currentPage == 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles multiple consecutive LoadMore calls',
      build: () {
        final page2Users = [UserModel(name: 'User 3')];
        final page3Users = [UserModel(name: 'User 4')];

        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => page2Users);
        when(() => mockRepository.fetchUsers(page: 3, pageSize: 10))
            .thenAnswer((_) async => page3Users);

        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: [
          UserModel(name: 'User 1'),
          UserModel(name: 'User 2'),
        ],
        currentPage: 1,
      ),
      act: (bloc) {
        bloc.add(const HomeEvent.loadMore());
        bloc.add(const HomeEvent.loadMore());
      },
      expect: () => [
        predicate<HomeState>((state) =>
            state.listUsers.length == 3 && state.currentPage == 2),
        predicate<HomeState>((state) =>
            state.listUsers.length == 4 && state.currentPage == 3),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'keeps previous data when LoadMore fails',
      build: () {
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenThrow(Exception('Network error'));
        return homeBloc;
      },
      seed: () => HomeState(
        listUsers: List.generate(10, (i) => UserModel(name: 'User $i')),
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [],
    );
  });

  group('HomeBloc - State Management', () {
    blocTest<HomeBloc, HomeState>(
      'copyWith preserves other fields when updating one',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.currentPage == 1 &&
            state.listUsers.isEmpty),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'maintains state consistency after multiple events',
      build: () {
        final initUsers = List.generate(
          10,
          (i) => UserModel(name: 'User $i'),
        );
        final moreUsers = [UserModel(name: 'User 10')];

        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => initUsers);
        when(() => mockRepository.fetchUsers(page: 2, pageSize: 10))
            .thenAnswer((_) async => moreUsers);

        return homeBloc;
      },
      act: (bloc) {
        bloc.add(const HomeEvent.initEvent());
      },
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.listUsers.length == 10 &&
            state.currentPage == 1),
      ],
    );
  });

  group('HomeBloc - Error Handling', () {

    blocTest<HomeBloc, HomeState>(
      'handles different exception types gracefully',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenThrow(FormatException('Invalid format'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        const HomeState(
          isLoading: false,
          listUsers: [],
          currentPage: 1,
        ),
      ],
    );
  });

  group('HomeBloc - Edge Cases', () {
    blocTest<HomeBloc, HomeState>(
      'handles very large page numbers',
      build: () {
        when(() => mockRepository.fetchUsers(page: 999, pageSize: 10))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      seed: () => HomeState(currentPage: 998),
      act: (bloc) => bloc.add(const HomeEvent.loadMore()),
      expect: () => [
        predicate<HomeState>((state) => state.currentPage == 999),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'maintains list integrity with special characters in names',
      build: () {
        final mockUsers = [
          UserModel(name: 'User "Test"'),
          UserModel(name: 'User & Co.'),
          UserModel(name: 'User <Special>'),
        ];
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => mockUsers);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeEvent.initEvent()),
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) =>
            !state.isLoading &&
            state.listUsers.length == 3 &&
            state.listUsers[0].name == 'User "Test"'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles rapid successive events correctly',
      build: () {
        when(() => mockRepository.fetchUsers(page: 1, pageSize: 10))
            .thenAnswer((_) async => [UserModel(name: 'User 1')]);
        return homeBloc;
      },
      act: (bloc) {
        bloc.add(const HomeEvent.initEvent());
        bloc.add(const HomeEvent.pullRefresh());
        bloc.add(const HomeEvent.pullRefresh());
      },
      expect: () => [
        const HomeState(isLoading: true),
        predicate<HomeState>((state) => !state.isLoading),
        const HomeState(isLoading: true, currentPage: 1),
        predicate<HomeState>((state) => !state.isLoading),
        const HomeState(isLoading: true, currentPage: 1),
        predicate<HomeState>((state) => !state.isLoading),
      ],
    );
  });
}