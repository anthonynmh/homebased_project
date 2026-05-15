import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2AccountScreen extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onModeChanged;

  const V2AccountScreen({
    super.key,
    required this.controller,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;

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
            user?.userType.description ?? 'Prototype account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF647067),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (user != null) _AccountPanel(controller: controller, user: user),
          const SizedBox(height: 12),
          _ModePanel(controller: controller, onModeChanged: onModeChanged),
          const SizedBox(height: 12),
          _StatsPanel(controller: controller),
          const SizedBox(height: 12),
          _PrototypePanel(controller: controller),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatefulWidget {
  final V2AppController controller;
  final V2CurrentUser user;

  const _AccountPanel({required this.controller, required this.user});

  @override
  State<_AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<_AccountPanel> {
  late final TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName,
    );
  }

  @override
  void didUpdateWidget(covariant _AccountPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.displayName != widget.user.displayName) {
      _displayNameController.text = widget.user.displayName;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

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
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(
                    0xFF176B87,
                  ).withValues(alpha: 0.13),
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
                        widget.user.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.user.email} · ${widget.user.userType.accountLabel}',
                        overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _displayNameController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  tooltip: 'Save display name',
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    widget.controller.updateDisplayName(_displayNameController.text);
    FocusScope.of(context).unfocus();
  }
}

class _ModePanel extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onModeChanged;

  const _ModePanel({required this.controller, required this.onModeChanged});

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
              'Mode',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<V2UserType>(
                segments: const [
                  ButtonSegment(
                    value: V2UserType.casual,
                    icon: Icon(Icons.explore_outlined),
                    label: Text('Casual user'),
                  ),
                  ButtonSegment(
                    value: V2UserType.owner,
                    icon: Icon(Icons.storefront_outlined),
                    label: Text('Owner'),
                  ),
                ],
                selected: {controller.userType},
                onSelectionChanged: (selection) {
                  controller.setUserType(selection.first);
                  onModeChanged();
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
    final ownerStore = controller.ownerStorefront;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatTile(
              icon: Icons.storefront_outlined,
              label: 'Subscribed',
              value: '${controller.subscribedCount}',
            ),
            _StatTile(
              icon: Icons.inventory_2_outlined,
              label: 'Products',
              value: ownerStore == null
                  ? '${controller.catalogItemCount}'
                  : '${controller.catalogFor(ownerStore.id).length}',
            ),
            _StatTile(
              icon: Icons.notifications_none,
              label: 'Unread',
              value: '${controller.unreadNotificationCount}',
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
      width: 148,
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
  final V2AppController controller;

  const _PrototypePanel({required this.controller});

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
            const Text(
              'Prototype settings',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const _SettingRow(
              icon: Icons.my_location_outlined,
              label: 'Location',
              value: 'Mocked neighborhood',
            ),
            const _SettingRow(
              icon: Icons.cloud_off_outlined,
              label: 'Backend',
              value: 'Frontend-only, locally persisted',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete mock account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB42318),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete mock account?'),
        content: const Text(
          'This clears locally saved prototype state and returns to login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteMockAccount();
    }
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
        children: [
          Icon(icon, color: const Color(0xFF176B87), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF39433E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF647067),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
