import 'package:flutter/material.dart';

class BusinessProductTypePage extends StatefulWidget {
  final String productType;
  final ValueChanged<String> onProductTypeChanged;
  final VoidCallback onNext;

  BusinessProductTypePage({
    required this.productType,
    required this.onProductTypeChanged,
    required this.onNext,
  });

  @override
  State<BusinessProductTypePage> createState() =>
      _BusinessProductTypePageState();
}

class _BusinessProductTypePageState extends State<BusinessProductTypePage> {
  late TextEditingController _productTypeController;

  @override
  void initState() {
    super.initState();
    _productTypeController = TextEditingController(text: widget.productType);
  }

  @override
  void dispose() {
    _productTypeController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.onProductTypeChanged(_productTypeController.text);
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
              'Cool name! Now what kind of services or goods do you want to sell?',
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
                  hintText: 'Select sector...',
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
