import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_schedule/storefront_schedule_model.dart';

/// Expose business profile related operations
final storefrontScheduleService = StorefrontScheduleService();

class StorefrontScheduleService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String table;

  StorefrontScheduleService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      table = _resolveTable(isTest);

  static String _resolveTable(bool isTest) {
    if (isTest) {
      return dotenv.env["STOREFRONT_SCHEDULE_STAGING"] ?? '';
    }
    const prodTable = String.fromEnvironment('STOREFRONT_SCHEDULE_PROD');
    return prodTable.isNotEmpty
        ? prodTable
        : dotenv.env["STOREFRONT_SCHEDULE_PROD"] ?? '';
  }

  /// Insert a new storefront monthly schedule (only id and email are required)
  Future<void> insertStorefrontMonthlySchedule(StorefrontSchedule profile) {
    try {
      return _supabase.from(table).insert(profile.toMap());
    } catch (e) {
      print('Insert storefront schedule error: $e');
      throw Exception('Failed to insert storefront monthly schedule');
    }
  }
}
