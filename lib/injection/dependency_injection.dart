import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/haptics_service.dart';
import '../data/datasources/counter_local_datasource.dart';
import '../data/repositories/counter_repository_impl.dart';
import '../domain/repositories/counter_repository.dart';
import '../presentation/counter/bloc/counter_bloc.dart';

final GetIt sl = GetIt.instance;

/// Registers app dependencies. [preferences] and [haptics] can be overridden
/// in tests.
Future<void> configureDependencies({
  SharedPreferences? preferences,
  HapticsService? haptics,
}) async {
  await sl.reset();
  final prefs = preferences ?? await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<HapticsService>(() => haptics ?? const PlatformHapticsService())
    ..registerLazySingleton<CounterLocalDataSource>(() => SharedPreferencesCounterDataSource(sl()))
    ..registerLazySingleton<CounterRepository>(() => CounterRepositoryImpl(sl()))
    ..registerFactory<CounterBloc>(() => CounterBloc(repository: sl(), haptics: sl()));
}
