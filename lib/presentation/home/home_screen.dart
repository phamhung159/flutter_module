import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/app/di/injection.dart';
import 'package:flutter_module/main.dart';
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart';

import 'widgets/user_list_widget.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? params;
  const HomeScreen({super.key, this.params});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  
  Future<void> _dismissFlutterModule() async {
    try {
      await sendChannel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _dismissFlutterModule,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'Test Call',
            onPressed: () {
              Navigator.of(context).pushNamed('/incall', arguments: {
                'calleeId': 'user123',
                'calleeName': 'Test User',
                'isVideo': false,
              });
            },
          ),
        ],
      ),
      body: BlocProvider<HomeBloc>(
        create: (context) => getIt<HomeBloc>()
          ..add(const HomeEvent.initEvent()),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            // Error handling if needed
          },
          child: const UsersListWidget(),
        ),
      ),
    );
  }
}