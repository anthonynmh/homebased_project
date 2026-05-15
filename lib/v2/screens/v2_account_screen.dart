import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';
import 'package:homebased_project/v2/widgets/v2_owner_widgets.dart';

class V2AccountScreen extends StatefulWidget {
  final V2AppController controller;
  final VoidCallback onModeChanged;

  const V2AccountScreen({
    super.key,
    required this.controller,
    required this.onModeChanged,
  });

  @override
  State<V2AccountScreen> createState() => _V2AccountScreenState();
}

class _V2AccountScreenState extends State<V2AccountScreen> {
  late final TextEditingController _displayNameController;
  bool _editingDisplayName = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.controller.currentUser?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final user = widget.controller.currentUser;
        if (user != null && !_editingDisplayName) {
          _displayNameController.text = user.displayName;
        }
        final ownerMode = widget.controller.userType == V2UserType.owner;

        return V2OwnerPage(
          children: [
            V2OwnerHeader(
              title: 'Account',
              subtitle: ownerMode
                  ? 'Manage your profile, storefronts, and owner settings.'
                  : 'Manage your profile and browsing preferences.',
              menu: _AccountMenu(
                controller: widget.controller,
                onEdit: () {
                  setState(() => _editingDisplayName = true);
                },
                onToggleMode: _toggleMode,
                onDelete: () => _confirmDelete(context),
              ),
            ),
            const SizedBox(height: 16),
            if (user != null)
              _ProfilePanel(
                user: user,
                onEdit: () => setState(() => _editingDisplayName = true),
              ),
            if (_editingDisplayName) ...[
              const SizedBox(height: 12),
              _EditNamePanel(
                controller: _displayNameController,
                onSave: _saveDisplayName,
              ),
            ],
            const SizedBox(height: 16),
            _StatsPanel(controller: widget.controller),
            if (ownerMode) ...[
              const SizedBox(height: 16),
              _StorefrontsPanel(
                controller: widget.controller,
                onCreate: () => _openCreateStorefront(context),
                onOpen: (storefront) => _openStorefront(context, storefront),
              ),
            ],
            const SizedBox(height: 16),
            _SettingsPanel(
              controller: widget.controller,
              onEditProfile: () => setState(() => _editingDisplayName = true),
              onToggleMode: _toggleMode,
              onLogout: widget.controller.logout,
            ),
          ],
        );
      },
    );
  }

  void _saveDisplayName() {
    widget.controller.updateDisplayName(_displayNameController.text);
    FocusScope.of(context).unfocus();
    setState(() => _editingDisplayName = false);
  }

  void _toggleMode() {
    final next = widget.controller.userType == V2UserType.casual
        ? V2UserType.owner
        : V2UserType.casual;
    widget.controller.setUserType(next);
    widget.onModeChanged();
  }

  void _openCreateStorefront(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2StorefrontFormSheet(
        title: 'Create storefront',
        onSubmit:
            ({
              required category,
              required description,
              required name,
              required pickupArea,
            }) {
              widget.controller.createStorefront(
                name: name,
                description: description,
                category: category,
                pickupArea: pickupArea,
              );
            },
      ),
    );
  }

  void _openStorefront(BuildContext context, V2Storefront storefront) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => V2StorefrontDetailScreen(
          controller: widget.controller,
          storefrontId: storefront.id,
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
          'This clears locally saved prototype state, including subscriptions, '
          'products, storefront edits, and replies. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.deleteMockAccount();
    }
  }
}

class _ProfilePanel extends StatelessWidget {
  final V2CurrentUser user;
  final VoidCallback onEdit;

  const _ProfilePanel({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return V2OwnerCard(
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: v2OwnerTeal.withValues(alpha: 0.12),
            child: const Icon(Icons.person, color: v2OwnerTeal, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: v2OwnerInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: v2OwnerMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                V2StatusChip(
                  label: user.userType.accountLabel,
                  color: const Color(0xFFEAF3EF),
                  textColor: v2OwnerTeal,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Edit profile',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _EditNamePanel extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const _EditNamePanel({required this.controller, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return V2OwnerCard(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSave(),
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(onPressed: onSave, child: const Text('Save')),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final V2AppController controller;

  const _StatsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final storefronts = controller.ownedStorefronts;
    final ownerProductCount = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.catalogFor(storefront.id).length,
    );

    return V2OwnerCard(
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          V2MetricChip(
            icon: Icons.storefront_outlined,
            label: controller.userType == V2UserType.owner
                ? 'storefronts'
                : 'subscribed',
            value: controller.userType == V2UserType.owner
                ? '${storefronts.length}'
                : '${controller.subscribedCount}',
          ),
          V2MetricChip(
            icon: Icons.inventory_2_outlined,
            label: 'products',
            value: controller.userType == V2UserType.owner
                ? '$ownerProductCount'
                : '${controller.catalogItemCount}',
          ),
          V2MetricChip(
            icon: Icons.notifications_none,
            label: 'unread',
            value: '${controller.unreadNotificationCount}',
          ),
        ],
      ),
    );
  }
}

class _StorefrontsPanel extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onCreate;
  final ValueChanged<V2Storefront> onOpen;

  const _StorefrontsPanel({
    required this.controller,
    required this.onCreate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final storefronts = controller.ownedStorefronts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        V2OwnerSectionHeader(
          title: 'Your storefronts',
          subtitle: 'Manage the business hubs attached to this account.',
          trailing: TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
        const SizedBox(height: 10),
        if (storefronts.isEmpty)
          V2OwnerEmptyState(
            icon: Icons.add_business_outlined,
            title: 'Create your first storefront',
            body: 'Set up a storefront to list products and collect interest.',
            action: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Create storefront'),
            ),
          )
        else
          ...storefronts.map(
            (storefront) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onOpen(storefront),
                  child: V2OwnerCard(
                    padding: const EdgeInsets.all(14),
                    color: Colors.white,
                    child: Row(
                      children: [
                        V2StorefrontAvatar(storefront: storefront, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storefront.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: v2OwnerInk,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${storefront.category} · ${controller.catalogFor(storefront.id).length} listings',
                                style: const TextStyle(
                                  color: v2OwnerMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Open storefront',
                          onPressed: () => onOpen(storefront),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onEditProfile;
  final VoidCallback onToggleMode;
  final VoidCallback onLogout;

  const _SettingsPanel({
    required this.controller,
    required this.onEditProfile,
    required this.onToggleMode,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return V2OwnerCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Account details',
            subtitle: 'Edit your public name and profile basics.',
            onTap: onEditProfile,
          ),
          _SettingsTile(
            icon: Icons.storefront_outlined,
            title: controller.userType == V2UserType.owner
                ? 'Storefront management'
                : 'Become a storefront owner',
            subtitle: controller.userType == V2UserType.owner
                ? 'Manage storefronts, listings, and community activity.'
                : 'Switch modes to set up a business hub.',
            // TODO: Route this to a dedicated storefront management page when
            // account-level nested routes exist.
            onTap: controller.userType == V2UserType.owner
                ? null
                : onToggleMode,
          ),
          const _SettingsTile(
            icon: Icons.notifications_none,
            title: 'Notification settings',
            subtitle: 'Prototype settings flow coming later.',
          ),
          const _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help and support',
            subtitle: 'Prototype support links coming later.',
          ),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign out',
            subtitle: 'Leave this local demo session.',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 28,
      leading: Icon(icon, color: v2OwnerTeal),
      title: Text(
        title,
        style: const TextStyle(color: v2OwnerInk, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: v2OwnerMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onEdit;
  final VoidCallback onToggleMode;
  final VoidCallback onDelete;

  const _AccountMenu({
    required this.controller,
    required this.onEdit,
    required this.onToggleMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final target = controller.userType == V2UserType.casual
        ? 'Switch to owner'
        : 'Switch to casual';
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _AccountAction.edit:
            onEdit();
          case _AccountAction.toggle:
            onToggleMode();
          case _AccountAction.logout:
            controller.logout();
          case _AccountAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _AccountAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit profile'),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.toggle,
          child: ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(target),
          ),
        ),
        const PopupMenuItem(
          value: _AccountAction.logout,
          child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ),
        const PopupMenuItem(
          value: _AccountAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Color(0xFFB42318)),
            title: Text('Delete account'),
          ),
        ),
      ],
    );
  }
}

enum _AccountAction { edit, toggle, logout, delete }
