import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final activityFeedPostService = ActivityFeedPostService();

class ActivityFeedPostService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String activityTable;
  final String activityBucket;

  ActivityFeedPostService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      activityTable = _resolveActivityTable(isTest),
      activityBucket = _resolveActivityBucket(isTest);

  static String _resolveActivityTable(bool isTest) {
    const prodTable = String.fromEnvironment('ACTIVITY_FEED_TABLE_PROD');
    return prodTable.isNotEmpty
        ? prodTable
        : dotenv.env["ACTIVITY_FEED_TABLE_PROD"] ?? '';
    // if (isTest) {
    //   return dotenv.env["BUSINESS_PROFILE_TABLE_STAGING"] ?? '';
    // }
    // const prodTable = String.fromEnvironment('BUSINESS_PROFILE_TABLE_PROD');
    // return prodTable.isNotEmpty
    //     ? prodTable
    //     : dotenv.env["BUSINESS_PROFILE_TABLE_PROD"] ?? '';
  }

  static String _resolveActivityBucket(bool isTest) {
    const prodBucket = String.fromEnvironment('ACTIVITY_FEED_BUCKET_PROD');
    return prodBucket.isNotEmpty
        ? prodBucket
        : dotenv.env["ACTIVITY_FEED_BUCKET_PROD"] ?? '';
    // if (isTest) {
    //   return dotenv.env["BUSINESS_PROFILE_BUCKET_STAGING"] ?? '';
    // }
    // const prodBucket = String.fromEnvironment('BUSINESS_PROFILE_BUCKET_PROD');
    // return prodBucket.isNotEmpty
    //     ? prodBucket
    //     : dotenv.env["BUSINESS_PROFILE_BUCKET_PROD"] ?? '';
  }

  Future<List<Post>> getAllPosts() async {
    try {
      final res = await _supabase
          .from('complete_posts')
          .select('*')
          .order('created_at', ascending: false);
      final posts = (res as List).map((e) => Post.fromMap(e)).toList();
      return posts;
    } catch (e) {
      print('Get posts error: $e');
      throw Exception('Failed to get posts');
    }
  }

  Future<void> insertPost(Post post) async {
    try {
      return await _supabase
          .from(activityTable)
          .insert(post.toMap());
    } catch (e) {
      print('Insert post error: $e');
      throw Exception('Failed to insert post');
    }
  }

  Future<void> insertLike(String postId, String userId) async {
    try {
      return await _supabase
          .from('post-likes')
          .insert({
            'post_id': postId,
            'liker_id': userId,
          });
    } catch (e) {
      print('Insert like error: $e');
      throw Exception('Failed to insert like');
    }
  }

  Future<void> removeLike(String postId, String userId) async {
    try {
      return await _supabase
          .from('post-likes')
          .delete()
          .eq('post_id', postId)
          .eq('liker_id', userId);
    } catch (e) {
      print('Remove like error: $e');
      throw Exception('Failed to remove like');
    }
  }
}