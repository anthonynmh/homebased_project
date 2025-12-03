import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likes;
  late int replies;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likes = widget.post['initialLikes'];
    replies = widget.post['initialReplies'];
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });
  }

  void incrementReply() {
    setState(() {
      replies++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.post['author'];
    final image = widget.post['image'];
    final content = widget.post['content'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(image, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(author['avatar']),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (author['businessName'] != null)
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
                            author['businessName'],
                            style: const TextStyle(
                              color: Color(0xFFD97A3D),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      Text(
                        widget.post['timestamp'],
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
              content,
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
