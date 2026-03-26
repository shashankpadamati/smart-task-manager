import 'package:flutter/material.dart';
import '../models/sub_task.dart';

class SubtaskTile extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const SubtaskTile({
    super.key,
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: subtask.completed,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
              activeColor: theme.colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.title,
              style: theme.textTheme.bodySmall?.copyWith(
                decoration:
                    subtask.completed ? TextDecoration.lineThrough : null,
                color: subtask.completed
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              icon: Icon(Icons.close_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              splashRadius: 14,
              tooltip: 'Remove subtask',
            ),
          ),
        ],
      ),
    );
  }
}
