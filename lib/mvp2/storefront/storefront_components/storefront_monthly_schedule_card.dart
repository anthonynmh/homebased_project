import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_day_selection_section.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_daily_hours_section.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_global_hours_picker.dart';

class MonthlyScheduleCard extends StatefulWidget {
  final int year;
  final int month;

  final Map<String, bool> initialOpenDays; // "YYYY-MM-DD": true/false
  final Map<String, Map<String, String>> initialDayHours;

  final void Function(Map<String, bool>) onSaveOpenDays;
  final void Function(Map<String, Map<String, String>>) onSaveDayHours;

  const MonthlyScheduleCard({
    super.key,
    required this.year,
    required this.month,
    required this.initialOpenDays,
    required this.initialDayHours,
    required this.onSaveOpenDays,
    required this.onSaveDayHours,
  });

  @override
  State<MonthlyScheduleCard> createState() => _MonthlyScheduleCardState();
}

class _MonthlyScheduleCardState extends State<MonthlyScheduleCard> {
  late Map<String, bool> openDays;
  late Map<String, Map<String, String>> dayHours;

  bool openDaysConfirmed = false;

  @override
  void initState() {
    super.initState();
    openDays = Map<String, bool>.from(widget.initialOpenDays);
    dayHours = Map<String, Map<String, String>>.from(widget.initialDayHours);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Schedule for ${widget.year}-${widget.month}"),

            const SizedBox(height: 20),

            DaySelectionSection(
              year: widget.year,
              month: widget.month,
              openDays: openDays,
              onToggle: (date, isOpen) {
                setState(() => openDays[date] = isOpen);
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                widget.onSaveOpenDays(openDays);
                setState(() => openDaysConfirmed = true);
              },
              child: const Text("Confirm Opening Days"),
            ),

            const SizedBox(height: 30),

            if (openDaysConfirmed)
              DailyHoursSection(
                openDays: openDays,
                dayHours: dayHours,
                onChange: (date, hours) {
                  setState(() => dayHours[date] = hours);
                },
              ),

            if (openDaysConfirmed) ...[
              const SizedBox(height: 20),
              GlobalHoursPicker(
                onApply: (start, end) {
                  setState(() {
                    openDays.forEach((date, isOpen) {
                      if (isOpen) {
                        dayHours[date] = {"start": start, "end": end};
                      }
                    });
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onSaveDayHours(dayHours);
                },
                child: const Text("Save Day Hours"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
