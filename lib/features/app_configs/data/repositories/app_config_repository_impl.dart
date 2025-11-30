import 'package:coexist_app_portal/features/app_configs/domain/model/app_config_model.dart';
import 'package:coexist_app_portal/features/app_configs/domain/model/customer_care_model.dart';
import 'package:coexist_app_portal/features/app_configs/domain/repository/app_config_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  final SupabaseClient _supabaseClient;

  AppConfigRepositoryImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<CustomerCareConfig> getCustomerCareConfig() async {
    final response = await _supabaseClient.from('config').select().inFilter(
      'key',
      ['customer_care_email', 'customer_care_number'],
    );

    if (response.isNotEmpty) {
      return CustomerCareConfig.fromList(response);
    } else {
      return CustomerCareConfig(email: null, number: null);
    }
  }

  @override
  Future<List<AppConfigModel>> getAppConfigs() async {
    try {
      final response = await _supabaseClient
          .from('config')
          .select()
          .inFilter('key', ['under_maintenance', 'shut_off'])
          .order('key', ascending: true);

      return (response as List)
          .map((json) => AppConfigModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch app configs: $e');
    }
  }

  @override
  Future<dynamic> getConfigByKey(String key) async {
    try {
      final response = await _supabaseClient
          .from('config')
          .select('value')
          .eq('key', key)
          .maybeSingle();

      if (response == null) return null;
      final value = response['value'];

      return value;
    } catch (e) {
      throw Exception('Failed to fetch config by key: $e');
    }
  }

  @override
  Future<List<AppConfigModel>> getHomeConfigs() async {
    try {
      final response = await _supabaseClient
          .from('config')
          .select()
          .inFilter('key', [
            'pickup_enable',
            'plant_tree_enable',
            'event_enable',
            'herbal_enable',
          ])
          .order('key', ascending: true);

      return (response as List)
          .map((json) => AppConfigModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch home configs: $e');
    }
  }
}
