import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';

const v2Ink = Color(0xFF17201D);
const v2Muted = Color(0xFF647067);
const v2Line = Color(0xFFE5DED4);
const v2Warm = Color(0xFFC46A35);
const v2Teal = Color(0xFF176B87);
const v2Card = Color(0xFFFFFCF7);
const v2Surface = Color(0xFFFAF7F1);

class V2Page extends StatelessWidget {
  final List<Widget> children;

  const V2Page({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: children,
          ),
        ),
      ),
    );
  }
}

class V2PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  final Widget? menu;

  const V2PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: v2Ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: v2Muted,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (menu != null) ...[const SizedBox(width: 8), menu!],
          ],
        ),
        if (action != null) ...[
          const SizedBox(height: 14),
          Align(alignment: Alignment.centerLeft, child: action!),
        ],
      ],
    );
  }
}

class V2SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const V2SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: v2Ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: v2Muted,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class V2Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  const V2Card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = v2Card,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: v2Line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class V2StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  const V2StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.color = const Color(0xFFFFF4E8),
    this.textColor = const Color(0xFF9A4F1F),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 14),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class V2MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const V2MetricChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: v2Line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: v2Teal, size: 18),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(color: v2Ink, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: v2Muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class V2StorefrontAvatar extends StatelessWidget {
  final V2Storefront storefront;
  final double size;

  const V2StorefrontAvatar({
    super.key,
    required this.storefront,
    this.size = 58,
  });

  @override
  Widget build(BuildContext context) {
    final initial = storefront.name.trim().isEmpty
        ? '?'
        : storefront.name.trim().substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3D7C2)),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: const Color(0xFF9A4F1F),
            fontWeight: FontWeight.w900,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

class V2ProductImage extends StatelessWidget {
  final String? imageUrl;
  final IconData icon;

  const V2ProductImage({
    super.key,
    this.imageUrl,
    this.icon = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: url == null || url.isEmpty
            ? DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF4E8), Color(0xFFEAF3EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(child: Icon(icon, color: v2Teal, size: 30)),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0xFFFFF4E8)),
                  child: Center(child: Icon(icon, color: v2Teal, size: 30)),
                ),
              ),
      ),
    );
  }
}

class V2EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const V2EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return V2Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: v2Teal, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: v2Ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              color: v2Muted,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class V2ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final double minTileWidth;
  final double spacing;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const V2ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minTileWidth = 340,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= minTileWidth * 2 + spacing
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            itemCount,
            (index) =>
                SizedBox(width: width, child: itemBuilder(context, index)),
          ),
        );
      },
    );
  }
}

class V2StorefrontSelector extends StatelessWidget {
  final List<V2Storefront> storefronts;
  final String? selectedStorefrontId;
  final ValueChanged<String?> onSelected;

  const V2StorefrontSelector({
    super.key,
    required this.storefronts,
    required this.selectedStorefrontId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All storefronts'),
              selected: selectedStorefrontId == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...storefronts.map(
            (storefront) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(storefront.name),
                selected: selectedStorefrontId == storefront.id,
                onSelected: (_) => onSelected(storefront.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
