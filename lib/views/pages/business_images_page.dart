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
      appBar: AppBar(title: Text('Add Business Images')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          SizedBox(
            width: 325,
            child: Column(
              children: [
                Text(
                  'Upload images of your business to attract more customers!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '(Press the button again to keep adding more images.)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 200),
          Center(
            child: ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add image', style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(_imagePaths[index]), height: 100),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleNext,
            child: Text('Continue', style: TextStyle(fontSize: 27)),
          ),
        ],
      ),
    );
  }
}
