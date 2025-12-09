import 'package:flutter/material.dart';

class StorefrontScheduleCard extends StatelessWidget {
  final Map<String, dynamic> weeklyTemplate;
  // Example:
  // {
  //   "mon": {"open": true, "start": "10:00", "end": "18:00"},
  //   "tue": {"open": false},
  //   ...
  // }

  final Map<String, dynamic> exceptions;
  // Example:
  // {
  //   "2025-01-14": {"open": false},
  //   "2025-01-20": {"open": true, "start": "12:00", "end": "17:00"}
  // }

  final void Function(Map<String, dynamic> updatedTemplate) onSaveTemplate;
  final void Function(String date, Map<String, dynamic> data) onSaveException;
  final void Function(String date) onDeleteException;

  const StorefrontScheduleCard({
    super.key,
    required this.weeklyTemplate,
    required this.exceptions,
    required this.onSaveTemplate,
    required this.onSaveException,
    required this.onDeleteException,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Store Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _WeeklyTemplateSection(
              template: weeklyTemplate,
              onSave: onSaveTemplate,
            ),

            const SizedBox(height: 20),

            _ExceptionsSection(
              exceptions: exceptions,
              onSave: onSaveException,
              onDelete: onDeleteException,
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------- WEEKLY TEMPLATE SECTION ----------------
//

class _WeeklyTemplateSection extends StatefulWidget {
  final Map<String, dynamic> template;
  final void Function(Map<String, dynamic>) onSave;

  const _WeeklyTemplateSection({required this.template, required this.onSave});

  @override
  State<_WeeklyTemplateSection> createState() => _WeeklyTemplateSectionState();
}

class _WeeklyTemplateSectionState extends State<_WeeklyTemplateSection> {
  late Map<String, dynamic> tempTemplate;

  final days = const [
    ["mon", "Mon"],
    ["tue", "Tue"],
    ["wed", "Wed"],
    ["thu", "Thu"],
    ["fri", "Fri"],
    ["sat", "Sat"],
    ["sun", "Sun"],
  ];

  @override
  void initState() {
    super.initState();
    tempTemplate = Map<String, dynamic>.from(widget.template);
  }

  Future<void> _pickTime(
    BuildContext context,
    String dayKey,
    bool isStart,
  ) async {
    final current = tempTemplate[dayKey]?[isStart ? "start" : "end"] ?? "09:00";

    final parts = current.split(":");
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      setState(() {
        tempTemplate[dayKey] ??= {"open": true};
        final h = picked.hour.toString().padLeft(2, "0");
        final m = picked.minute.toString().padLeft(2, "0");
        tempTemplate[dayKey][isStart ? "start" : "end"] = "$h:$m";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Template",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        Column(
          children: days.map((d) {
            final key = d[0];
            final label = d[1];
            final data = tempTemplate[key] ?? {"open": false};
            final open = data["open"] == true;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label)),
                    Switch(
                      value: open,
                      onChanged: (v) {
                        setState(() {
                          tempTemplate[key] = {
                            "open": v,
                            if (v) "start": "09:00",
                            if (v) "end": "17:00",
                          };
                        });
                      },
                    ),
                  ],
                ),
                if (open)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _pickTime(context, key, true),
                        child: Text("Start: ${data["start"]}"),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => _pickTime(context, key, false),
                        child: Text("End: ${data["end"]}"),
                      ),
                    ],
                  ),
                const Divider(),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => widget.onSave(tempTemplate),
            icon: const Icon(Icons.save),
            label: const Text("Save Weekly Template"),
          ),
        ),
      ],
    );
  }
}

//
// ---------------- EXCEPTIONS EDIT SECTION ----------------
//

class _ExceptionsSection extends StatelessWidget {
  final Map<String, dynamic> exceptions;
  final void Function(String date, Map<String, dynamic> data) onSave;
  final void Function(String date) onDelete;

  const _ExceptionsSection({
    required this.exceptions,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = exceptions.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Exceptions (Next 4 Weeks)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        if (sortedDates.isEmpty) const Text("No exceptions added."),

        if (sortedDates.isNotEmpty)
          Column(
            children: sortedDates.map((date) {
              final ex = exceptions[date];
              final open = ex["open"] == true;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(date),
                  subtitle: Text(
                    open ? "${ex['start']}–${ex['end']}" : "Closed",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await _editExceptionDialog(
                            context,
                            date,
                            ex,
                          );
                          if (result != null) onSave(date, result);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete(date),
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

  Future<Map<String, dynamic>?> _editExceptionDialog(
    BuildContext context,
    String date,
    Map<String, dynamic> ex,
  ) async {
    bool open = ex["open"] == true;
    String start = ex["start"] ?? "09:00";
    String end = ex["end"] ?? "17:00";

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $date"),
        content: StatefulBuilder(
          builder: (context, setModal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Open"),
                  value: open,
                  onChanged: (v) => setModal(() => open = v),
                ),
                if (open)
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final res = await _pickTime(context, start);
                          if (res != null) {
                            setModal(() => start = res);
                          }
                        },
                        child: Text("Start: $start"),
                      ),
                      TextButton(
                        onPressed: () async {
                          final res = await _pickTime(context, end);
                          if (res != null) {
                            setModal(() => end = res);
                          }
                        },
                        child: Text("End: $end"),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop<Map<String, dynamic>>(context, {
                "open": open,
                if (open) "start": start,
                if (open) "end": end,
              });
            },
            child: const Text("Save"),
          ),
        ],
      ),
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
