import 'package:flutter/material.dart';

class GlobalHoursPicker extends StatefulWidget {
  final void Function(String start, String end) onApply;

  const GlobalHoursPicker({super.key, required this.onApply});

  @override
  State<GlobalHoursPicker> createState() => _GlobalHoursPickerState();
}

class _GlobalHoursPickerState extends State<GlobalHoursPicker> {
  String start = "09:00";
  String end = "17:00";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Global Opening Hours",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            TextButton(
              onPressed: () async {
                final res = await _pickTime(context, start);
                if (res != null) setState(() => start = res);
              },
              child: Text("Start: $start"),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () async {
                final res = await _pickTime(context, end);
                if (res != null) setState(() => end = res);
              },
              child: Text("End: $end"),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: () => widget.onApply(start, end),
          child: const Text("Apply to All Open Days"),
        ),
      ],
    );
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(":");
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return null;

    final h = picked.hour.toString().padLeft(2, "0");
    final m = picked.minute.toString().padLeft(2, "0");
    return "$h:$m";
  }
}
