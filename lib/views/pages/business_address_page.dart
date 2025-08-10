import 'package:flutter/material.dart';

class BusinessAddressPage extends StatefulWidget {
  final String address;
  final ValueChanged<String> onAddressChanged;
  final VoidCallback onNext;

  BusinessAddressPage({
    required this.address,
    required this.onAddressChanged,
    required this.onNext,
  });

  @override
  State<BusinessAddressPage> createState() => _BusinessAddressPageState();
}

class _BusinessAddressPageState extends State<BusinessAddressPage> {
  late TextEditingController _productTypeController;

  @override
  void initState() {
    super.initState();
    _productTypeController = TextEditingController(text: widget.address);
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
              'Where will you be doing your business?',
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
                  hintText: 'Enter location...',
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
                child: Text('Continue', style: TextStyle(fontSize: 27)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
