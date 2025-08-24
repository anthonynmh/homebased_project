import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessImagesPage extends StatefulWidget {
  final List<String>? imagePaths;
  final ValueChanged<List<String>> onImagesChanged;
  final VoidCallback onNext;

  BusinessImagesPage({
    required this.imagePaths,
    required this.onImagesChanged,
    required this.onNext,
  });

  @override
  State<BusinessImagesPage> createState() => _BusinessImagesPageState();
}

class _BusinessImagesPageState extends State<BusinessImagesPage> {
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    _imagePaths = widget.imagePaths ?? [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
      widget.onImagesChanged(_imagePaths);
    }
  }

  void _handleNext() {
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: 325,
            child: Column(
              children: const [
                Text(
                  'Upload images of your business to attract more customers!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          /// Grid of images + add button at the end
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _imagePaths.length + 1, // +1 for the add button
              itemBuilder: (context, index) {
                if (index == _imagePaths.length) {
                  // Last item = "Add Image" button
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
                  );
                } else {
                  final imagePath = _imagePaths[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 237, // Set your desired width
              height: 74, // Set your desired height
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(
                  _imagePaths.isEmpty ? 'Skip for now' : 'Continue',
                  style: TextStyle(fontSize: 27, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
