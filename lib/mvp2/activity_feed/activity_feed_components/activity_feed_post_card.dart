import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/activity_feed_post_model.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';


class PostCard extends StatelessWidget {
  final Post post;
  final bool isLiked;

  final VoidCallback? toggleLike;
  final VoidCallback? incrementReply;

  const PostCard({
    super.key,
    required this.post,
    this.isLiked = false,
    this.toggleLike,
    this.incrementReply
  });

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final likes = post.initialLikes;
    final replies = post.initialReplies;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(post.image!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(author.avatar),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (author.businessName != null)
                        Container(
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
                            author.businessName!,
                            style: const TextStyle(
                              color: Color(0xFFD97A3D),
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
              post.content,
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