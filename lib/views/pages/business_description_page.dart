import 'package:flutter/material.dart';

class BusinessDescriptionPage extends StatefulWidget {
  final String address;
  final ValueChanged<String> onAddressChanged;
  final VoidCallback onNext;

  BusinessDescriptionPage({
    required this.address,
    required this.onAddressChanged,
    required this.onNext,
  });

  @override
  State<BusinessDescriptionPage> createState() =>
      _BusinessDescriptionPageState();
}

class _BusinessDescriptionPageState extends State<BusinessDescriptionPage> {
  late TextEditingController _productTypeController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _productTypeController = TextEditingController(text: widget.address);
    _productTypeController.addListener(() {
      setState(() {
        _isTyping = _productTypeController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _productTypeController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.onAddressChanged(_productTypeController.text);
    widget.onNext();
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
              'Write a short description of your business',
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
                controller: _productTypeController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(
                  _isTyping ? 'Continue' : 'Skip For Now',
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
