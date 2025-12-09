import 'package:flutter/material.dart';

class DaySelectionSection extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, bool> openDays;
  final void Function(String date, bool isOpen) onToggle;

  const DaySelectionSection({
    super.key,
    required this.year,
    required this.month,
    required this.openDays,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Opening Days",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final day = index + 1;
            final date =
                "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            final selected = openDays[date] == true;

            return GestureDetector(
              onTap: () => onToggle(date, !selected),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selected
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
                child: Text(day.toString()),
              ),
            );
          },
        ),
      ],
    );
  }
}
