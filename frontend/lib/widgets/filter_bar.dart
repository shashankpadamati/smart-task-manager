import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final chipTheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Sort Dropdown ──
          _buildDropdown<String>(
            context: context,
            icon: Icons.sort_rounded,
            value: tp.sortBy,
            items: const {
              'newest': 'Newest first',
              'alphabetical': 'A → Z',
              'priority': 'Priority ↓',
            },
            onChanged: (v) => tp.setSortBy(v!),
          ),
          const SizedBox(width: 8),

          // ── Filter: Incomplete Only ──
          FilterChip(
            label: const Text('Incomplete'),
            selected: tp.filterCompleted == false,
            onSelected: (sel) =>
                tp.setFilterCompleted(sel ? false : null),
            avatar: Icon(Icons.radio_button_unchecked,
                size: 16,
                color: tp.filterCompleted == false
                    ? chipTheme.onPrimary
                    : chipTheme.onSurface.withValues(alpha: 0.5)),
            selectedColor: chipTheme.primary,
            checkmarkColor: chipTheme.onPrimary,
            labelStyle: TextStyle(
              color: tp.filterCompleted == false
                  ? chipTheme.onPrimary
                  : chipTheme.onSurface,
            ),
            side: BorderSide(
              color: tp.filterCompleted == false
                  ? chipTheme.primary
                  : chipTheme.outline.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),

          // ── Filter: High Priority ──
          FilterChip(
            label: const Text('High Priority'),
            selected: tp.filterPriority == 'HIGH',
            onSelected: (sel) =>
                tp.setFilterPriority(sel ? 'HIGH' : null),
            avatar: Icon(Icons.flag_rounded,
                size: 16,
                color: tp.filterPriority == 'HIGH'
                    ? chipTheme.onPrimary
                    : Colors.red.shade300),
            selectedColor: Colors.red.shade400,
            checkmarkColor: chipTheme.onPrimary,
            labelStyle: TextStyle(
              color: tp.filterPriority == 'HIGH'
                  ? Colors.white
                  : chipTheme.onSurface,
            ),
            side: BorderSide(
              color: tp.filterPriority == 'HIGH'
                  ? Colors.red.shade400
                  : chipTheme.outline.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),

          // ── Tag Filter ──
          if (tp.allTags.isNotEmpty)
            _buildDropdown<String?>(
              context: context,
              icon: Icons.label_rounded,
              value: tp.filterTag,
              items: {
                null: 'All Tags',
                for (var tag in tp.allTags) tag: tag,
              },
              onChanged: (v) => tp.setFilterTag(v),
            ),

          if (tp.filterCompleted != null ||
              tp.filterPriority != null ||
              tp.filterTag != null ||
              tp.searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Clear'),
              avatar: const Icon(Icons.clear_all_rounded, size: 16),
              onPressed: () => tp.clearFilters(),
              side: BorderSide(
                  color: chipTheme.outline.withValues(alpha: 0.3)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required IconData icon,
    required T value,
    required Map<T, String> items,
    required void Function(T?) onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              dropdownColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              items: items.entries
                  .map((e) => DropdownMenuItem<T>(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
