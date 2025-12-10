import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_model.dart';

final activityFeedPostService = ActivityFeedPostService();

class ActivityFeedPostService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String table;
  final String bucket;

  ActivityFeedPostService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      table = _resolveTable(isTest),
      bucket = _resolveBucket(isTest);

  static String _resolveTable(bool isTest) {
    return String.fromEnvironment('ACTIVITY_FEED_TABLE_PROD');
    // if (isTest) {
    //   return dotenv.env["BUSINESS_PROFILE_TABLE_STAGING"] ?? '';
    // }
    // const prodTable = String.fromEnvironment('BUSINESS_PROFILE_TABLE_PROD');
    // return prodTable.isNotEmpty
    //     ? prodTable
    //     : dotenv.env["BUSINESS_PROFILE_TABLE_PROD"] ?? '';
  }

  static String _resolveBucket(bool isTest) {
    return String.fromEnvironment('ACTIVITY_FEED_POST_BUCKET');
    // if (isTest) {
    //   return dotenv.env["BUSINESS_PROFILE_BUCKET_STAGING"] ?? '';
    // }
    // const prodBucket = String.fromEnvironment('BUSINESS_PROFILE_BUCKET_PROD');
    // return prodBucket.isNotEmpty
    //     ? prodBucket
    //     : dotenv.env["BUSINESS_PROFILE_BUCKET_PROD"] ?? '';
  }

  Future<List<Post>> getPosts() async {
    try {
      final res = await _supabase
          .from(table)
          .select()
          .order('timestamp', ascending: false);

      final posts = (res as List).map((e) => Post.fromMap(e)).toList();
      return posts;
    } catch (e) {
      print('Get posts error: $e');
      throw Exception('Failed to get posts');
    }
  }
}