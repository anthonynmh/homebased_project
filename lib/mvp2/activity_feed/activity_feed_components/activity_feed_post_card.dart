import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback toggleLike;
  final VoidCallback incrementReply;
  final bool isLiked;

  const PostCard({
    super.key, 
    required this.post,
    required this.toggleLike,
    required this.incrementReply,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    final likes = post.likeCount;
    final replies = post.numReplies;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.postPhotoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(post.postPhotoUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: post.avatarUrl != null && post.avatarUrl != ""
                    ? NetworkImage(post.avatarUrl!) 
                    : AssetImage('assets/defaultUser.png'),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.fullName != null && post.fullName != "" 
                        ? post.fullName!
                        : (post.username ?? ''),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      post.businessName != null 
                        ? Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA366).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              post.businessName!,
                              style: const TextStyle(
                                color: Color(0xFFD97A3D),
                                fontSize: 11,
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 130, 102, 255).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Customer",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 131, 44, 218),
                                fontSize: 11,
                              ),
                            ),
                          ),

                      Text(
                        post.timestamp,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.postText,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
                Text('$likes'),
                IconButton(
                  onPressed: incrementReply,
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                ),
                Text('$replies'),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}