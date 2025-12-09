import 'package:flutter/material.dart';
import 'package:flutter_module/presentation/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart';

class MockHomeBloc extends Mock implements HomeBloc {
  @override
  Stream<HomeState> get stream => _stream;
  final Stream<HomeState> _stream;

  MockHomeBloc({required Stream<HomeState> stream}) : _stream = stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    // ✨ Setup GetIt for tests
    final getIt = GetIt.instance;
    
    // ✨ Register mock bloc before tests
    final mockBloc = MockHomeBloc(
      stream: Stream.value(const HomeState(isLoading: true)),
    );

    when(() => mockBloc.state).thenReturn(
      const HomeState(isLoading: true),
    );

    getIt.registerSingleton<HomeBloc>(mockBloc);
  });
  
  group('Screenshot: Home Screen', () {
    // ✨ 1. Loading State
    _screenshot(
      '1_home_loading',
      setupTest: (getIt) {
        final mockBloc = MockHomeBloc(
          stream: Stream.value(const HomeState(isLoading: true)),
        );

        when(() => mockBloc.state).thenReturn(
          const HomeState(isLoading: true),
        );

        getIt.registerSingleton<HomeBloc>(mockBloc);
      },
    );
  });
}

void _screenshot(
  String description, {
  required void Function(GetIt getIt) setupTest,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    testGoldens('for iPhone 12', (WidgetTester tester) async {
      // ✨ Setup GetIt before each test
      final getIt = GetIt.instance;
      await getIt.reset();
      setupTest(getIt);

      // ✨ Build the app
      await tester.pumpWidgetBuilder(
        HomeScreen(),
        surfaceSize: const Size(1206, 2622),
      );

      await beforeScreenshot?.call(tester);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, '$description/iphone_12');
    });
  }); 
}
