import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final String bucket;

  MenuService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      table = _resolveTable(isTest),
      bucket = _resolveBucket(isTest);

  static String _resolveTable(bool isTest) {
    if (isTest) {
      return dotenv.env["MENU_TABLE_STAGING"] ?? '';
    }
    const prodTable = String.fromEnvironment('MENU_TABLE_PROD');
    return prodTable.isNotEmpty
        ? prodTable
        : dotenv.env["MENU_TABLE_PROD"] ?? '';
  }

  static String _resolveBucket(bool isTest) {
    if (isTest) {
      return dotenv.env["MENU_BUCKET_STAGING"] ?? '';
    }
    const prodBucket = String.fromEnvironment('MENU_BUCKET_PROD');
    return prodBucket.isNotEmpty
        ? prodBucket
        : dotenv.env["MENU_BUCKET_PROD"] ?? '';
  }

  Future<void> uploadMenuItemPhoto({
    required XFile imageFile,
    required MenuItem item,
  }) async {
    final ext = path.extension(imageFile.name);
    final filename = 'photo$ext';
    final filepath = '${item.userId}/menu/${item.name}/$filename';

    try {
      final bytes = await imageFile.readAsBytes();

      // Remove old photo if exists
      if (item.photoPath != null && item.photoPath!.isNotEmpty) {
        try {
          await _supabase.storage.from(bucket).remove([item.photoPath!]);
        } catch (_) {}
      }

      await _supabase.storage.from(bucket).uploadBinary(filepath, bytes);

      // Update DB with new path
      await updateMenuItem(
        item.copyWith(
          photoPath: filepath,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (e, st) {
      print('Upload menu item photo error: $e\n$st');
      throw Exception('Failed to upload menu item photo');
    }
  }

  Future<String?> getMenuItemPhotoFilepath(
    String userId,
    String itemName,
  ) async {
    try {
      final res = await _supabase
          .from(table)
          .select('photo_url')
          .eq('user_id', userId)
          .eq('item_name', itemName)
          .maybeSingle();

      final filepath = res?['photo_url'] as String?;

      return filepath;
    } catch (e, st) {
      print('Get menu item photo filepath error: $e\n$st');
      return null;
    }
  }

  Future<String?> getMenuItemPhotoSignedUrl(
    String userId,
    String itemName,
  ) async {
    try {
      final filePath = await getMenuItemPhotoFilepath(userId, itemName);
      if (filePath == null) return null;

      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(filePath, 60); // 60 seconds validity
      return signedUrl;
    } catch (e, st) {
      print('Get menu item photo signed URL error: $e\n$st');
      return null;
    }
  }

  Future<void> deleteMenuItemPhotoByPath(String filepath) async {
    final storage = _supabase.storage;
    try {
      debugPrint('Deleting photo at path: $filepath');
      await storage.from(bucket).remove([filepath]);
    } catch (e) {
      print('Delete menu item photo by path error: $e');
    }
  }

  Future<void> deleteMenuItemPhoto(MenuItem item) async {
    final storage = _supabase.storage;
    debugPrint('userId=${item.userId}, itemName=${item.name}');
    final filepath =
        await getMenuItemPhotoFilepath(item.userId, item.name) ?? '';

    try {
      debugPrint('Deleting photo at path: $filepath');
      await storage.from(bucket).remove([filepath]);

      await updateMenuItem(
        item.copyWith(
          photoPath: null,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (e) {
      print('Delete menu item photo error: $e');
    }
  }

  Future<void> insertMenuItem(MenuItem item) async {
    try {
      Map<String, dynamic> payload = item.toMap();
      debugPrint('Inserting menu item: $payload');
      final response = await _supabase.from(table).insert(payload);
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
      return res.map((row) => MenuItem.fromMap(row)).toList();
    } catch (e) {
      print('Get user menu items error: $e');
      rethrow;
    }
  }

  Future<void> updateMenuItem(MenuItem item) {
    try {
      return _supabase
          .from(table)
          .update(item.toMap())
          .eq('user_id', item.userId)
          .eq('item_name', item.name);
    } catch (e) {
      print('Update menu item error: $e');
      throw Exception('Failed to update menu item');
    }
  }

  Future<void> deleteMenuItem(String userId, String name) {
    try {
      return _supabase
          .from(table)
          .delete()
          .eq('user_id', userId)
          .eq('item_name', name);
    } catch (e) {
      print('Delete menu item error: $e');
      throw Exception('Failed to delete menu item');
    }
  }
}
