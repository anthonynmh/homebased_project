import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  final VoidCallback onClose;

  const CreatePostDialog({Key? key, required this.onClose}) : super(key: key);

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  bool showImageField = false;

  void handlePost() {
    final content = contentController.text.trim();
    if (content.isEmpty) return;
    debugPrint('Posting: $content, Image: ${imageController.text}');
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Text(
                  'Create Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
            if (showImageField)
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  hintText: "Image URL",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.image_outlined),
                  label: const Text("Add Image"),
                  onPressed: () =>
                      setState(() => showImageField = !showImageField),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: widget.onClose,
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA366),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: handlePost,
                      child: const Text(
                        "Post",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
