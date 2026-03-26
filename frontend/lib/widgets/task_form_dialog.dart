import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/sub_task.dart';
import '../providers/task_provider.dart';
import '../widgets/tag_chip.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task; // null = create mode

  const TaskFormDialog({super.key, this.task});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagCtrl;
  String _priority = 'MEDIUM';
  DateTime? _dueDate;
  List<SubTask> _subtasks = [];
  List<String> _tags = [];
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _tagCtrl = TextEditingController();
    if (t != null) {
      _priority = t.priority;
      _dueDate = t.dueDate;
      _subtasks = t.subtasks.map((s) => s.copyWith()).toList();
      _tags = List.from(t.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 700 ? 520.0 : screenWidth * 0.9;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 620),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.primary.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditing
                          ? Icons.edit_note_rounded
                          : Icons.add_task_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isEditing ? 'Edit Task' : 'New Task',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: _inputDecoration(
                          theme, 'Title *', Icons.title_rounded),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Title is required' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descCtrl,
                        decoration: _inputDecoration(
                            theme, 'Description', Icons.notes_rounded),
                        maxLines: 3,
                        minLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Priority + Due Date row
                      Row(
                        children: [
                          // Priority
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Priority',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.6))),
                                const SizedBox(height: 6),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                        value: 'LOW',
                                        label: Text('Low'),
                                        icon: Icon(Icons.arrow_downward_rounded,
                                            size: 16)),
                                    ButtonSegment(
                                        value: 'MEDIUM',
                                        label: Text('Med'),
                                        icon: Icon(Icons.remove_rounded,
                                            size: 16)),
                                    ButtonSegment(
                                        value: 'HIGH',
                                        label: Text('High'),
                                        icon: Icon(Icons.arrow_upward_rounded,
                                            size: 16)),
                                  ],
                                  selected: {_priority},
                                  onSelectionChanged: (s) =>
                                      setState(() => _priority = s.first),
                                  style: ButtonStyle(
                                    visualDensity: VisualDensity.compact,
                                    textStyle: WidgetStatePropertyAll(
                                      theme.textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Due date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due Date',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.6))),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _pickDueDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.3)),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .calendar_today_rounded,
                                            size: 16,
                                            color: theme
                                                .colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _dueDate != null
                                                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                                : 'None',
                                            style: theme
                                                .textTheme.bodySmall
                                                ?.copyWith(
                                              color: _dueDate != null
                                                  ? theme.colorScheme
                                                      .onSurface
                                                  : theme.colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                        if (_dueDate != null)
                                          GestureDetector(
                                            onTap: () => setState(
                                                () => _dueDate = null),
                                            child: Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.4)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tags
                      Text('Tags',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagCtrl,
                              style: theme.textTheme.bodySmall,
                              decoration: InputDecoration(
                                hintText: 'Add a tag...',
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
                                          .withValues(alpha: 0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.primary),
                                ),
                                prefixIcon: Icon(Icons.label_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: FilledButton.tonalIcon(
                              onPressed: _addTag,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add'),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                textStyle: theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _tags
                              .map((t) => TagChip(
                                    label: t,
                                    onRemove: () => setState(
                                        () => _tags.remove(t)),
                                  ))
                              .toList(),
                        ),
                      ],

                      // Subtasks (only in create mode, edit mode uses inline)
                      if (!_isEditing) ...[
                        const SizedBox(height: 20),
                        Text('Subtasks',
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6))),
                        const SizedBox(height: 6),
                        ..._subtasks.asMap().entries.map((entry) {
                          final i = entry.key;
                          final st = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(st.title,
                                      style: theme.textTheme.bodySmall),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 14),
                                  onPressed: () => setState(
                                      () => _subtasks.removeAt(i)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      maxWidth: 24, maxHeight: 24),
                                ),
                              ],
                            ),
                          );
                        }),
                        _buildAddSubtaskField(theme),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Footer ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(_isEditing
                              ? Icons.save_rounded
                              : Icons.add_task_rounded, size: 18),
                      label:
                          Text(_isEditing ? 'Save Changes' : 'Create Task'),
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

  Widget _buildAddSubtaskField(ThemeData theme) {
    final ctrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            style: theme.textTheme.bodySmall,
            decoration: InputDecoration(
              hintText: 'Add subtask...',
              hintStyle: TextStyle(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color:
                        theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color:
                        theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                setState(() => _subtasks.add(SubTask(title: v.trim())));
                ctrl.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 36,
          width: 36,
          child: IconButton.filled(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(
                    () => _subtasks.add(SubTask(title: ctrl.text.trim())));
                ctrl.clear();
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      ThemeData theme, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      prefixIcon:
          Icon(icon, size: 18, color: theme.colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagCtrl.clear();
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = Task(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      subtasks: _subtasks,
      tags: _tags,
    );

    final tp = context.read<TaskProvider>();
    bool success;
    if (_isEditing) {
      success = await tp.updateTask(widget.task!.id!, task);
    } else {
      success = await tp.createTask(task);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Navigator.pop(context);
      } else if (tp.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tp.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
