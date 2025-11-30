import 'package:coexist_app_portal/features/app_configs/data/repositories/app_config_repository_impl.dart';
import 'package:coexist_app_portal/features/app_configs/domain/repository/app_config_repository.dart';
import 'package:coexist_app_portal/features/app_configs/presentation/bloc/app_config_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void registerAppConfigDependencies(GetIt sl) {
  // Repository: register under the abstract type so other features can
  // depend on AppConfigRepository (interface) instead of the concrete impl.
  sl.registerLazySingleton<AppConfigRepository>(
    () => AppConfigRepositoryImpl(supabaseClient: sl<SupabaseClient>()),
  );

  // BLoC
  sl.registerFactory(
    () => AppConfigBloc(repository: sl<AppConfigRepository>()),
  );
}
