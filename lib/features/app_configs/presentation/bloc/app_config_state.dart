// import removed duplicate
import 'package:coexist_app_portal/features/app_configs/domain/model/app_config_model.dart';
import 'package:coexist_app_portal/features/app_configs/domain/model/customer_care_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppConfigState extends Equatable {
  const AppConfigState();

  @override
  List<Object?> get props => [];
}

class AppConfigInitial extends AppConfigState {
  const AppConfigInitial();
}

class AppConfigLoading extends AppConfigState {
  const AppConfigLoading();
}

class AppConfigLoaded extends AppConfigState {
  final List<AppConfigModel> configs;

  const AppConfigLoaded(this.configs);

  @override
  List<Object?> get props => [configs];
}

class HomeConfigLoaded extends AppConfigState {
  final List<AppConfigModel> configs;

  const HomeConfigLoaded({required this.configs});

  @override
  List<Object?> get props => [configs];
}

class AppConfigByKeyLoaded extends AppConfigState {
  final AppConfigModel? config;

  const AppConfigByKeyLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class AppConfigDialogRequired extends AppConfigState {
  final AppConfigModel config;

  const AppConfigDialogRequired(this.config);

  @override
  List<Object?> get props => [config];
}

class AppConfigDialogDismissed extends AppConfigState {
  final String configKey;

  const AppConfigDialogDismissed(this.configKey);

  @override
  List<Object?> get props => [configKey];
}

class AppConfigError extends AppConfigState {
  final String message;

  const AppConfigError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerCareConfigLoaded extends AppConfigState {
  final CustomerCareConfig careConfig;

  const CustomerCareConfigLoaded({required this.careConfig});

  @override
  List<Object?> get props => [careConfig];
}
