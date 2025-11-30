import 'package:coexist_app_portal/features/app_configs/domain/model/app_config_model.dart';
import 'package:coexist_app_portal/features/app_configs/domain/model/customer_care_model.dart';

abstract class AppConfigRepository {
  Future<List<AppConfigModel>> getAppConfigs();
  Future<dynamic> getConfigByKey(String key);
  Future<CustomerCareConfig> getCustomerCareConfig();
  Future<List<AppConfigModel>> getHomeConfigs();
}
