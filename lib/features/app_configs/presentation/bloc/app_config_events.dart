import 'package:equatable/equatable.dart';

abstract class AppConfigEvent extends Equatable {
  const AppConfigEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeConfigsEvent extends AppConfigEvent {
  const FetchHomeConfigsEvent();
}

class FetchConfigByKeyEvent extends AppConfigEvent {
  final String key;

  const FetchConfigByKeyEvent(this.key);

  @override
  List<Object?> get props => [key];
}

class FetchCustomerCareConfigEvent extends AppConfigEvent {
  const FetchCustomerCareConfigEvent();

  @override
  List<Object?> get props => [];
}

class CheckEnabledConfigsEvent extends AppConfigEvent {
  const CheckEnabledConfigsEvent();
}

class DismissConfigDialogEvent extends AppConfigEvent {
  final String configKey;

  const DismissConfigDialogEvent(this.configKey);

  @override
  List<Object?> get props => [configKey];
}
