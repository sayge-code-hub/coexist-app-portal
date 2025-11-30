import 'package:coexist_app_portal/core/network/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/repositories/event_repository.dart';
import '../presentation/bloc/event_bloc.dart';

/// Register event dependencies
void registerEventDependencies(GetIt sl) {
  // Repository
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      supabaseClient: sl<SupabaseClient>(),
      apiClient: sl<ApiClient>(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => EventBloc(
      eventRepository: sl<EventRepository>(),
      supabaseClient: sl<SupabaseClient>(),
    ),
  );
}
