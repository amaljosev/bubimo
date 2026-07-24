// lib/features/help/presentation/pages/help_screen.dart
import 'package:bubimo/features/help/data/faq_data.dart';
import 'package:bubimo/features/help/domain/faq_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



/// Top-level Help / FAQ screen.
///
/// Static content grouped by [FaqCategory]. Tapping an item pushes the
/// [FaqDetailScreen] via GoRouter (see app_router.dart wiring below).
///
/// This is a plain StatelessWidget — no Bloc — since the data is fully
/// static and there's no state to manage beyond navigation.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = FaqData.groupedByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // One entry per category header + its items, flattened into a
        // single scroll list.
        itemCount: grouped.length,
        itemBuilder: (context, sectionIndex) {
          final category = grouped.keys.elementAt(sectionIndex);
          final items = grouped[category]!;
          return _FaqSection(
            category: category,
            items: items,
            theme: theme,
          );
        },
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final FaqCategory category;
  final List<FaqItem> items;
  final ThemeData theme;

  const _FaqSection({
    required this.category,
    required this.items,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(category.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _FaqListTile(item: item, colorScheme: colorScheme)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FaqListTile extends StatelessWidget {
  final FaqItem item;
  final ColorScheme colorScheme;

  const _FaqListTile({required this.item, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          item.question,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // Named route, params passed via GoRouterState.extra since
          // FaqItem isn't a primitive.
          context.push('/help/detail', extra: item);
        },
      ),
    );
  }
}