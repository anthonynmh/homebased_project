import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_service.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import '../activity_feed_components/activity_feed_post_card.dart';
import '../activity_feed_components/activity_feed_create_post_dialog.dart';

class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  State<ActivityFeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<ActivityFeedPage> {
  bool _isDialogOpen = false;

  late Future<List<Post>> futurePosts;

  late Future<Map<String, bool>> futureLikeStatuses;

  // --- functions for post card ---
  void toggleLikeEntry(Post post) {
    if (post.isLiked) {
      // unlike
      ActivityFeedPostService().removeLike(post.postId, authService.currentUserId!);
    } else {
      // like
      ActivityFeedPostService().insertLike(post.postId, authService.currentUserId!);
    }
  }

  void incrementReply(int index) {
    
  }

  Future<List<Post>> fetchPosts() async {
    return await ActivityFeedPostService().getAllPosts();
  }

  Future<List<Post>> addTempPost(Post cachedPost) async {
    final list = await futurePosts;
    if (list.any((post) => post.postId == cachedPost.postId)) {
      print("Post already exists in list");
      return list;
    }
    print("Adding post locally.");
    list.add(cachedPost);
    return list;
  }

  // Future<List<Post>> toggleTempLike(int index, Post tempPost) async {
  //   final posts = await futurePosts;
  //   setState(() {
  //     posts[index] = tempPost;
  //   });
  //   return posts;
  // }

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const LinearGradient(
                colors: [Color(0xFFD8E7F5), Color(0xFFF9FBFD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(const Rect.fromLTWH(0, 0, 1, 1)) !=
              null // dummy check to preserve gradient
          ? const Color(0xFFF9FBFD)
          : null,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white.withOpacity(0.95),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEB885), Color(0xFFFFA366)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "knock knock",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Business owners you follow",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFFFA366)),
            onPressed: () => setState(() => _isDialogOpen = true),
          ),
        ],
      ),
      body: FutureBuilder(
        future: futurePosts, 
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Post> postData = snapshot.data!;
            // Use the loaded data to build your widget
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: postData.length,
              itemBuilder: (context, index) => PostCard(
                post: postData[index], 
                isLiked: postData[index].isLiked, //likeStatuses[postData[index].postId] ?? false, 
                toggleLike: () => setState(() {
                  toggleLikeEntry(postData[index]);
                  postData[index] = postData[index].copyWith(
                    isLiked: !postData[index].isLiked,
                    likeCount: postData[index].isLiked
                      ? postData[index].likeCount - 1
                      : postData[index].likeCount + 1,
                  );
                }), //toggleLike(postData[index].postId, likeStatuses), 
                incrementReply: () => incrementReply(index),
              ),
            );
          }
        }),
      floatingActionButton: _isDialogOpen
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFFA366),
              onPressed: () => setState(() => _isDialogOpen = true),
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomSheet: _isDialogOpen
          ? CreatePostDialog(
              onClose: () => setState(() => _isDialogOpen = false),
              onPost: (newPost) => setState(() {
                ActivityFeedPostService().insertPost(newPost);
                _isDialogOpen = false;
                futurePosts = fetchPosts();
                futurePosts = addTempPost(newPost);
              }),
            )
          : null,
    );
  }
}
