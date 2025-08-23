import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

enum FieldType { text, dropdown, images }

class CustomFormField extends StatefulWidget {
  final String label;
  final FieldType type;
  final String? initialValue;
  final List<String>? initialImages;
  final FormFieldSetter<String>? onSaved;
  final bool readOnly;
  final int maxLines;

  const CustomFormField({
    super.key,
    required this.label,
    required this.type,
    this.initialValue,
    this.initialImages,
    this.onSaved,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<CustomFormField> createState() => CustomFormFieldState();
}

class CustomFormFieldState extends State<CustomFormField> {
  late List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.initialImages ?? []);
  }

  @override
  void didUpdateWidget(covariant CustomFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.type == FieldType.images &&
        !listEquals(widget.initialImages, oldWidget.initialImages)) {
      _images = List<String>.from(widget.initialImages ?? []);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FieldType.text:
        return Container(
          width: 300,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                initialValue: widget.initialValue ?? "",
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (val) => val == null || val.isEmpty
                    ? "This field cannot be empty"
                    : null,
                onSaved: widget.onSaved,
              ),
            ],
          ),
        );
      case FieldType.dropdown:
        // Placeholder for dropdown implementation
        return Container(
          width: 300,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
              DropdownButtonFormField<String>(
                value: widget.initialValue,
                items: ['Food & Beverages', 'Services']
                    .map(
                      (option) =>
                          DropdownMenuItem(value: option, child: Text(option)),
                    )
                    .toList(),
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        widget.onSaved?.call(val);
                      },
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (val) => val == null || val.isEmpty
                    ? "This field cannot be empty"
                    : null,
                onSaved: widget.onSaved,
              ),
            ],
          ),
        );
      case FieldType.images:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (widget.readOnly) {
                  if (index == _images.length) {
                    return const SizedBox.shrink();
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_images[index]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  }
                } else {
                  if (index == _images.length) {
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
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _images.removeAt(index);
                        });
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_images[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 37, 37, 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.close,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
    }
  }

  List<String> getImages() => List<String>.unmodifiable(_images);
}
