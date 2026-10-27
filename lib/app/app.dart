import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../presentation/counter/bloc/counter_bloc.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class MusmilesApp extends StatelessWidget {
  const MusmilesApp({super.key, required this.counterBloc});

  /// Created and initialised before the first frame so the saved count is on
  /// screen immediately, never a placeholder.
  final CounterBloc counterBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: counterBloc,
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.counter,
        routes: AppRoutes.routes,
      ),
    );
  }
}
