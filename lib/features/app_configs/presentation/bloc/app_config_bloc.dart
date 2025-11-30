import 'package:coexist_app_portal/features/app_configs/domain/repository/app_config_repository.dart';
import 'package:coexist_app_portal/features/app_configs/presentation/bloc/app_config_events.dart';
import 'package:coexist_app_portal/features/app_configs/presentation/bloc/app_config_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  final AppConfigRepository repository;
  final Set<String> _dismissedConfigs = <String>{};

  AppConfigBloc({required this.repository}) : super(const AppConfigInitial()) {
    on<FetchCustomerCareConfigEvent>(_onFetchCustomerCareConfig);
    on<FetchConfigByKeyEvent>(_onFetchConfigByKey);
    on<CheckEnabledConfigsEvent>(_onCheckEnabledConfigs);
    on<DismissConfigDialogEvent>(_onDismissConfigDialog);
    on<FetchHomeConfigsEvent>(_onFetchHomeConfigs);
  }

  Future<void> _onFetchHomeConfigs(
    FetchHomeConfigsEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    try {
      emit(const AppConfigLoading());
      final configs = await repository.getHomeConfigs();
      emit(HomeConfigLoaded(configs: configs));
    } catch (e) {
      emit(AppConfigError(e.toString()));
    }
  }

  Future<void> _onFetchCustomerCareConfig(
    FetchCustomerCareConfigEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    try {
      emit(const AppConfigLoading());
      final careConfig = await repository.getCustomerCareConfig();
      emit(CustomerCareConfigLoaded(careConfig: careConfig));
    } catch (e) {
      emit(AppConfigError(e.toString()));
    }
  }

  Future<void> _onFetchConfigByKey(
    FetchConfigByKeyEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    try {
      emit(const AppConfigLoading());
      final config = await repository.getConfigByKey(event.key);
      emit(AppConfigByKeyLoaded(config));
    } catch (e) {
      emit(AppConfigError(e.toString()));
    }
  }

  Future<void> _onCheckEnabledConfigs(
    CheckEnabledConfigsEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    try {
      // emit(const AppConfigLoading());
      final configs = await repository.getAppConfigs();

      // Check if all configs have value == false
      final allConfigsDisabled = configs.every(
        (config) => config.value == 'false' || config.value == false,
      );

      if (allConfigsDisabled) {
        // No need to show any dialog — all are disabled
        emit(AppConfigLoaded(configs));
        return;
      }

      // Find the first enabled config that hasn't been dismissed
      for (final config in configs) {
        if (config.isEnabled && !_dismissedConfigs.contains(config.key)) {
          emit(AppConfigDialogRequired(config));
          return;
        }
      }

      // If no enabled configs found, emit loaded state
    } catch (e) {
      emit(AppConfigError(e.toString()));
    }
  }

  void _onDismissConfigDialog(
    DismissConfigDialogEvent event,
    Emitter<AppConfigState> emit,
  ) {
    _dismissedConfigs.add(event.configKey);
    emit(AppConfigDialogDismissed(event.configKey));

    // Check for next enabled config after dismissing current one
    add(const CheckEnabledConfigsEvent());
  }
}
