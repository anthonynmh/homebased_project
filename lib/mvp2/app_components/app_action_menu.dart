import 'package:flutter/material.dart';

class AppActionMenuItem {
  final String value;
  final String label;
  final bool enabled;

  const AppActionMenuItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}

class AppActionMenu extends StatelessWidget {
  final List<AppActionMenuItem> items;
  final Future<void> Function(String value) onSelected;

  const AppActionMenu({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => onSelected(value),
      itemBuilder: (_) {
        return items
            .where((item) => item.enabled)
            .map(
              (item) =>
                  PopupMenuItem(value: item.value, child: Text(item.label)),
            )
            .toList();
      },
    );
  }
}
