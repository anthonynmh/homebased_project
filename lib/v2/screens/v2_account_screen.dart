import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2AccountScreen extends StatelessWidget {
  final V2AppController controller;

  const V2AccountScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Account',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF17201D),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Switch roles and review prototype state.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF647067),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _AccountPanel(controller: controller),
          const SizedBox(height: 12),
          _ModePanel(controller: controller),
          const SizedBox(height: 12),
          _StatsPanel(controller: controller),
          const SizedBox(height: 12),
          const _PrototypePanel(),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  final V2AppController controller;

  const _AccountPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF176B87).withValues(alpha: 0.13),
              child: const Icon(
                Icons.person,
                color: Color(0xFF176B87),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo user',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.mode.description,
                    style: const TextStyle(
                      color: Color(0xFF647067),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePanel extends StatelessWidget {
  final V2AppController controller;

  const _ModePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<V2UserMode>(
                segments: const [
                  ButtonSegment(
                    value: V2UserMode.casual,
                    icon: Icon(Icons.explore_outlined),
                    label: Text('Casual'),
                  ),
                  ButtonSegment(
                    value: V2UserMode.lister,
                    icon: Icon(Icons.storefront_outlined),
                    label: Text('Lister'),
                  ),
                ],
                selected: {controller.mode},
                onSelectionChanged: (selection) {
                  controller.setMode(selection.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final V2AppController controller;

  const _StatsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local state',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatTile(
                  icon: Icons.location_on_outlined,
                  label: 'Nearby',
                  value: '${controller.nearbyListings.length}',
                ),
                _StatTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Subscribed',
                  value: '${controller.subscribedCount}',
                ),
                _StatTile(
                  icon: Icons.visibility_off_outlined,
                  label: 'Rejected',
                  value: '${controller.rejectedCount}',
                ),
                _StatTile(
                  icon: Icons.storefront_outlined,
                  label: 'Owned',
                  value: '${controller.ownedListings.length}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF176B87), size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF17201D),
                      ),
                    ),
                    Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrototypePanel extends StatelessWidget {
  const _PrototypePanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prototype settings',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            SizedBox(height: 12),
            _SettingRow(
              icon: Icons.map_outlined,
              label: 'Map',
              value: 'MapLibre GL with OpenFreeMap Positron',
            ),
            _SettingRow(
              icon: Icons.my_location_outlined,
              label: 'Location',
              value: 'Mocked Singapore center',
            ),
            _SettingRow(
              icon: Icons.radio_button_checked,
              label: 'Radius',
              value: '2KM interest-check area',
            ),
            _SettingRow(
              icon: Icons.cloud_off_outlined,
              label: 'Backend',
              value: 'Disconnected, in-memory only',
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Color(0xFF176B87)),
          SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF647067),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFF17201D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
