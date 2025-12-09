import 'package:flutter/material.dart';

class DailyHoursSection extends StatelessWidget {
  final Map<String, bool> openDays; // only true days matter
  final Map<String, Map<String, String>> dayHours;
  final void Function(String date, Map<String, String> hours) onChange;

  const DailyHoursSection({
    super.key,
    required this.openDays,
    required this.dayHours,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final openedDates =
        openDays.entries.where((e) => e.value).map((e) => e.key).toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Set Opening Hours",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Column(
          children: openedDates.map((date) {
            final existing = dayHours[date];
            final start = existing?["start"] ?? "09:00";
            final end = existing?["end"] ?? "17:00";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(date),
                subtitle: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final res = await _pickTime(context, start);
                        if (res != null) {
                          onChange(date, {"start": res, "end": end});
                        }
                      },
                      child: Text("Start: $start"),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        final res = await _pickTime(context, end);
                        if (res != null) {
                          onChange(date, {"start": start, "end": res});
                        }
                      },
                      child: Text("End: $end"),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
