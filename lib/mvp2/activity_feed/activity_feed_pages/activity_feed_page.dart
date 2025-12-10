import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
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
  int? numLikes;

  final List<Post> posts = [
    Post(
      postId: "1",
      userId: "8123084712834718257981247958123740850", 
      username: "sarahj",
      fullName: "Sarah Johnson",
      avatarUrl:
          "https://images.unsplash.com/photo-1592849902530-cbabb686381d",
      businessName: "Creative Studio Co.",
      postText: "Just launched our new product today! 🚀 So excited to share this with everyone. What do you think?", 
      postPhotoUrl: "https://images.unsplash.com/photo-1524758631624-e2822e304c36",
      timestamp: "2h", 
      numLikes: 142, 
      numReplies: 23, 
      isFollowing: true
    )
  ];

  final List<Map<String, dynamic>> likes = [
    {
      "id": "1", 
      "isLiked": false
    }
  ];

  // --- functions for post card ---
  void toggleLike(int index) {
    Post oldPost = posts[index];
    bool wasLiked = likes[index]['isLiked'];
    Post updatedPost = oldPost.copyWith(
      initialLikes: wasLiked ? 
        oldPost.numLikes - 1 : 
        oldPost.numLikes + 1,
    );
    setState(() {
      posts[index] = updatedPost;
      likes[index]['isLiked'] = !wasLiked;
    });
  }

  void incrementReply(int index) {
    Post oldPost = posts[index];
    Post updatedPost = oldPost.copyWith(
      initialReplies: oldPost.numReplies + 1,
    );
    setState(() {
      posts[index] = updatedPost;
    });
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
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        itemBuilder: (context, index) => PostCard(
          post: posts[index], 
          isLiked: likes[index]['isLiked'], 
          toggleLike: () => toggleLike(index), 
          incrementReply: () => incrementReply(index),
        ),
        // itemBuilder: (context, index) => PostCard(post: mockPosts[index]),
      ),
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
                posts.insert(0, newPost);
                likes.insert(0, {"id": newPost.postId, "isLiked": false});
                _isDialogOpen = false;
              }),
            )
          : null,
    );
  }
}
