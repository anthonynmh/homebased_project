import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleDay {
  DateTime date;
  bool isOpen;
  String openTime;
  String closeTime;
  String remarks;

  ScheduleDay({
    required this.date,
    this.isOpen = false,
    this.openTime = "09:00",
    this.closeTime = "17:00",
    this.remarks = "",
  });
}

class StorefrontPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontPage({super.key, this.onBroadcast});

  @override
  State<StorefrontPage> createState() => _StorefrontState();
}

class _StorefrontState extends State<StorefrontPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  int _selectedDayIndex = 0;

  late List<ScheduleDay> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = _generateNext14Days();
  }

  List<ScheduleDay> _generateNext14Days() {
    final today = DateTime.now();
    return List.generate(14, (i) {
      final date = today.add(Duration(days: i));
      return ScheduleDay(date: date);
    });
  }

  void _toggleDay(int index) {
    setState(() {
      _schedule[index].isOpen = !_schedule[index].isOpen;
    });
  }

  void _updateScheduleField(int index, String field, String value) {
    setState(() {
      final day = _schedule[index];
      switch (field) {
        case 'openTime':
          day.openTime = value;
          break;
        case 'closeTime':
          day.closeTime = value;
          break;
        case 'remarks':
          day.remarks = value;
          break;
      }
    });
  }

  void _handleBroadcastSchedule() {
    final openDays = _schedule.where((d) => d.isOpen).toList();
    if (openDays.isNotEmpty && widget.onBroadcast != null) {
      final firstDay = openDays.first;
      final formattedDate = DateFormat('MMMM d').format(firstDay.date);
      final message =
          '${_nameController.text.isEmpty ? "Our store" : _nameController.text} has updated their schedule! '
          'We are open on $formattedDate from ${firstDay.openTime} to ${firstDay.closeTime}.';
      widget.onBroadcast!(message);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('E, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const LinearGradient(
                colors: [Color(0xFFD8E7F5), Color(0xFFF9FBFD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromLTWH(0, 0, 0, 0)) ==
              null
          ? const Color(0xFFF9FBFD)
          : null,
      appBar: AppBar(
        title: const Text("Storefront Management"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Manage your store information and schedule",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStoreInfoCard(context),
            const SizedBox(height: 16),
            _buildScheduleCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Store Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Store Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_pin, color: Colors.orange),
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            if (_locationController.text.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("View on Google Maps"),
                onPressed: () async {
                  final query = Uri.encodeComponent(_locationController.text);
                  final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$query',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: const StadiumBorder(),
              ),
              onPressed: () {},
              child: const Text("Save Store Information"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Opening Hours (Next 2 Weeks)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.message_outlined, size: 16),
          label: const Text("Broadcast Update"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            shape: const StadiumBorder(),
          ),
          onPressed: _handleBroadcastSchedule,
        ),
      ],
    );
  }

  Widget _buildDayEditor(BuildContext context, ScheduleDay day) {
    return Card(
      color: day.isOpen ? Colors.orange.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(day.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: () => setState(() => day.isOpen = !day.isOpen),
                  style: TextButton.styleFrom(
                    foregroundColor: day.isOpen ? Colors.white : Colors.orange,
                    backgroundColor: day.isOpen
                        ? Colors.orange
                        : Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(day.isOpen ? "Open" : "Closed"),
                ),
              ],
            ),
            if (day.isOpen) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: "Open Time"),
                      controller: TextEditingController(text: day.openTime),
                      onChanged: (v) => _updateScheduleField(
                        _selectedDayIndex,
                        'openTime',
                        v,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Close Time",
                      ),
                      controller: TextEditingController(text: day.closeTime),
                      onChanged: (v) => _updateScheduleField(
                        _selectedDayIndex,
                        'closeTime',
                        v,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Remarks (optional)",
                ),
                controller: TextEditingController(text: day.remarks),
                onChanged: (v) =>
                    _updateScheduleField(_selectedDayIndex, 'remarks', v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _schedule.length,
                itemBuilder: (context, index) {
                  final day = _schedule[index];
                  final isSelected = index == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(day.date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${day.date.day}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildDayEditor(context, _schedule[_selectedDayIndex]),
          ],
        ),
      ),
    );
  }
}
