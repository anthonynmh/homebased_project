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
  final List<String> productTypes = ['Food & Beverages', 'Services'];

  late String? _selectedProductType;

  @override
  void initState() {
    super.initState();
    _selectedProductType = widget.productType.isNotEmpty
        ? widget.productType
        : null;
  }

  void _handleNext() {
    if (_selectedProductType == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Select a sector'),
          content: Text('Please choose a product type before continuing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onProductTypeChanged(_selectedProductType!);
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
              child: DropdownButtonFormField<String>(
                value: _selectedProductType,
                hint: Text('Select a product type'),
                items: productTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProductType = newValue;
                  });
                },
                decoration: InputDecoration(
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
                  backgroundColor: _selectedProductType == null
                      ? Colors.grey
                      : Colors.orange,
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
