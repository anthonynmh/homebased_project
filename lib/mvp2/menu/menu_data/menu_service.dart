import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

/// Expose menu item related operations
final menuService = MenuService();

class MenuService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String table;

  MenuService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      table = _resolveTable(isTest);

  static String _resolveTable(bool isTest) {
    if (isTest) {
      return dotenv.env["MENU_TABLE_STAGING"] ?? '';
    }
    const prodTable = String.fromEnvironment('MENU_TABLE_PROD');
    return prodTable.isNotEmpty
        ? prodTable
        : dotenv.env["MENU_TABLE_PROD"] ?? '';
  }

  Future<void> insertMenuItem(MenuItem item) async {
    try {
      final response = await _supabase.from(table).insert(item.toMap());
      print("Insert response: $response");
    } catch (e) {
      print('Insert menu item error: $e');
      throw Exception('Failed to insert menu item');
    }
  }

  Future<List<MenuItem>> getUserMenuItems(String userId) async {
    try {
      final res = await _supabase.from(table).select().eq('user_id', userId);

      // res is List<dynamic>
      return res
          .map((row) => MenuItem.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Get user menu items error: $e');
      rethrow;
    }
  }

  Future<void> updateMenuItem(MenuItem item) {
    try {
      return _supabase.from(table).update(item.toMap()).eq('id', item.id);
    } catch (e) {
      print('Update menu item error: $e');
      throw Exception('Failed to update menu item');
    }
  }
}
