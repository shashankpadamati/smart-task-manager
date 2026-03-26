import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/tag_chip.dart';
import '../widgets/subtask_tile.dart';
import 'task_form_dialog.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  final _subtaskController = TextEditingController();

  static const _priorityColors = {
    'HIGH': Color(0xFFEF4444),
    'MEDIUM': Color(0xFFF59E0B),
    'LOW': Color(0xFF22C55E),
  };

  static const _priorityLabels = {
    'HIGH': 'High',
    'MEDIUM': 'Medium',
    'LOW': 'Low',
  };

  Color get _accentColor =>
      _priorityColors[widget.task.priority] ?? const Color(0xFFF59E0B);

  bool get _isOverdue =>
      !widget.task.completed && AppDateUtils.isOverdue(widget.task.dueDate);

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: task.completed
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: task.completed ? theme.colorScheme.outline.withValues(alpha: 0.2) : _accentColor,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TaskProvider>()
                              .toggleComplete(task.id!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.completed
                                ? _accentColor
                                : Colors.transparent,
                            border: Border.all(
                              color: task.completed
                                  ? _accentColor
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: task.completed
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title + description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.completed
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (task.description != null &&
                                task.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description!,
                                maxLines: _expanded ? 10 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Actions
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (v) => _handleMenuAction(v, context),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ])),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_rounded,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ])),
                        ],
                      ),
                    ],
                  ),

                  // ── Meta Row ──
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Priority badge
                      _buildBadge(
                        context,
                        Icons.flag_rounded,
                        _priorityLabels[task.priority] ?? 'Medium',
                        _accentColor,
                      ),

                      // Due date badge
                      if (task.dueDate != null)
                        _buildBadge(
                          context,
                          Icons.calendar_today_rounded,
                          AppDateUtils.dueDateLabel(task.dueDate),
                          _isOverdue
                              ? Colors.red
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          isOverdue: _isOverdue,
                        ),

                      // Subtask count
                      if (task.subtasks.isNotEmpty)
                        _buildBadge(
                          context,
                          Icons.checklist_rounded,
                          '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                          theme.colorScheme.primary,
                        ),

                      // Created time
                      _buildBadge(
                        context,
                        Icons.access_time_rounded,
                        AppDateUtils.timeAgo(task.createdAt),
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),

                      // Tags
                      ...task.tags.map((t) => TagChip(label: t)),
                    ],
                  ),

                  // ── Expanded: Subtasks ──
                  if (_expanded && task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.15)),
                    const SizedBox(height: 4),
                    ...task.subtasks.map((st) => SubtaskTile(
                          subtask: st,
                          onToggle: () => context
                              .read<TaskProvider>()
                              .toggleSubTaskComplete(task.id!, st.id!),
                          onDelete: () => context
                              .read<TaskProvider>()
                              .deleteSubTask(task.id!, st.id!),
                        )),
                  ],

                  // ── Expanded: Add Subtask ──
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskController,
                            style: theme.textTheme.bodySmall,
                            decoration: InputDecoration(
                              hintText: 'Add subtask...',
                              hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.primary),
                              ),
                            ),
                            onSubmitted: (_) => _addSubtask(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: IconButton.filled(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            onPressed: () => _addSubtask(context),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, IconData icon, String text, Color color,
      {bool isOverdue = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isOverdue
            ? Border.all(color: Colors.red.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask(BuildContext context) {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;
    context.read<TaskProvider>().addSubTask(widget.task.id!, title);
    _subtaskController.clear();
  }

  void _handleMenuAction(String action, BuildContext context) {
    final tp = context.read<TaskProvider>();
    if (action == 'edit') {
      showDialog(
        context: context,
        builder: (_) => TaskFormDialog(task: widget.task),
      );
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Task'),
          content:
              const Text('Are you sure you want to delete this task?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                tp.deleteTask(widget.task.id!);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
