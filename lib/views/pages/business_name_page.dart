import 'package:flutter/material.dart';

class BusinessNamePage extends StatefulWidget {
  final String name;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onNext;

  BusinessNamePage({
    required this.name,
    required this.onNameChanged,
    required this.onNext,
  });

  @override
  State<BusinessNamePage> createState() => _BusinessNamePageState();
}

class _BusinessNamePageState extends State<BusinessNamePage> {
  late TextEditingController _nameController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _nameController.addListener(() {
      setState(() {
        _isTyping = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_nameController.text.trim().isEmpty) {
      // Show alert if empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Missing Business Name"),
          content: Text("Please enter a business name before continuing."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      widget.onNameChanged(_nameController.text.trim());
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          SizedBox(
            height: 87,
            width: 325,
            child: Text(
              'Looking to start your own business? Great! What would you like to name it?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 200),
          Center(
            child: SizedBox(
              width: 314,
              child: TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter business name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 80),
          Center(
            child: SizedBox(
              width: 237, // Set your desired width
              height: 74, // Set your desired height
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTyping ? Colors.orange : Colors.grey,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 27, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
