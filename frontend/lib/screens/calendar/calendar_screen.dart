import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/task_form_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDay = DateTime.now();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<DateTime, List<Task>> _groupTasksByDueDate(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (final t in tasks) {
      if (t.dueDate != null) {
        final key = _stripTime(t.dueDate!);
        map.putIfAbsent(key, () => []).add(t);
      }
    }
    return map;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    // pad start to align with weekday (Mon=1)
    final startWeekday = first.weekday; // 1=Mon ... 7=Sun
    final startDate = first.subtract(Duration(days: startWeekday - 1));
    // always show 6 rows = 42 cells
    return List.generate(42, (i) => startDate.add(Duration(days: i)));
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      _selectedDay = null;
    });
    _animCtrl.forward(from: 0);
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      _selectedDay = null;
    });
    _animCtrl.forward(from: 0);
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDay = DateTime.now();
    });
    _animCtrl.forward(from: 0);
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final grouped = _groupTasksByDueDate(tp.tasks);
    final days = _daysInMonth(_focusedMonth);
    final today = _stripTime(DateTime.now());

    final selectedTasks = _selectedDay != null
        ? (grouped[_stripTime(_selectedDay!)] ?? [])
        : <Task>[];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.04),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor:
                  theme.colorScheme.surface.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 70,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Calendar',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    themeProvider.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip:
                      themeProvider.isDark ? 'Light mode' : 'Dark mode',
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Month Header ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _prevMonth,
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: theme
                              .colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _goToToday,
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMMM yyyy')
                                    .format(_focusedMonth),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap to go to today',
                                style:
                                    theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: theme
                              .colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Weekday Labels ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: d == 'Sun' || d == 'Sat'
                                    ? theme.colorScheme.error
                                        .withValues(alpha: 0.5)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            // ── Calendar Grid ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: days.length,
                    itemBuilder: (ctx, i) {
                      final day = days[i];
                      final stripped = _stripTime(day);
                      final isCurrentMonth =
                          day.month == _focusedMonth.month;
                      final isToday = _sameDay(stripped, today);
                      final isSelected = _selectedDay != null &&
                          _sameDay(stripped, _stripTime(_selectedDay!));
                      final tasksOnDay = grouped[stripped] ?? [];
                      final hasOverdue = tasksOnDay.any((t) =>
                          !t.completed &&
                          AppDateUtils.isOverdue(t.dueDate));
                      final allCompleted = tasksOnDay.isNotEmpty &&
                          tasksOnDay.every((t) => t.completed);

                      return _CalendarDayCell(
                        day: day,
                        isCurrentMonth: isCurrentMonth,
                        isToday: isToday,
                        isSelected: isSelected,
                        taskCount: tasksOnDay.length,
                        hasOverdue: hasOverdue,
                        allCompleted: allCompleted,
                        onTap: () {
                          setState(() => _selectedDay = day);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Legend ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _legendItem(theme, theme.colorScheme.primary, 'Tasks due'),
                    _legendItem(theme, Colors.red, 'Overdue'),
                    _legendItem(theme, const Color(0xFF22C55E), 'All done'),
                  ],
                ),
              ),
            ),

            // ── Selected Day Tasks ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Icon(Icons.event_note_rounded,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDay != null
                          ? _sameDay(
                                  _stripTime(_selectedDay!), today)
                              ? 'Today\'s Tasks'
                              : DateFormat('EEEE, MMM d')
                                  .format(_selectedDay!)
                          : 'Select a day',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (selectedTasks.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectedTasks.length} task${selectedTasks.length == 1 ? '' : 's'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (selectedTasks.isEmpty && _selectedDay != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.event_available_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text(
                        'No tasks due on this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const TaskFormDialog(),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Create a task'),
                      ),
                    ],
                  ),
                ),
              ),

            if (selectedTasks.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = selectedTasks[index];
                    return _CalendarTaskTile(task: task);
                  },
                  childCount: selectedTasks.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

// ── Calendar Day Cell ─────────────────────────────────────

class _CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final int taskCount;
  final bool hasOverdue;
  final bool allCompleted;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.taskCount,
    required this.hasOverdue,
    required this.allCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bgColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      bgColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.12);
      textColor = theme.colorScheme.primary;
      border = Border.all(color: theme.colorScheme.primary, width: 1.5);
    } else {
      bgColor = isCurrentMonth
          ? null
          : theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3);
      textColor = isCurrentMonth
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurface.withValues(alpha: 0.25);
    }

    // Dot color for tasks
    Color dotColor;
    if (hasOverdue) {
      dotColor = Colors.red;
    } else if (allCompleted) {
      dotColor = const Color(0xFF22C55E);
    } else {
      dotColor = theme.colorScheme.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight:
                    isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            if (taskCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  taskCount.clamp(0, 3),
                  (i) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                              .withValues(alpha: 0.7)
                          : dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Task Tile ────────────────────────────────────

class _CalendarTaskTile extends StatelessWidget {
  final Task task;
  const _CalendarTaskTile({required this.task});

  static const _priorityColors = {
    'HIGH': Color(0xFFEF4444),
    'MEDIUM': Color(0xFFF59E0B),
    'LOW': Color(0xFF22C55E),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.read<TaskProvider>();
    final accentColor =
        _priorityColors[task.priority] ?? const Color(0xFFF59E0B);
    final isOverdue =
        !task.completed && AppDateUtils.isOverdue(task.dueDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: task.completed
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: GestureDetector(
              onTap: () => tp.toggleComplete(task.id!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      task.completed ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: task.completed
                        ? accentColor
                        : theme.colorScheme.outline
                            .withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
            ),
            title: Text(
              task.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? theme.colorScheme.onSurface
                        .withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.checklist_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(width: 2),
                  Text(
                    '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
            trailing: task.dueDate != null
                ? Text(
                    DateFormat('h:mm a').format(task.dueDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isOverdue
                          ? Colors.red
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
