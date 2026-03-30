import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    final tp = context.read<TaskProvider>();
    tp.loadTasks();
    tp.loadTags();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final tp = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Separate active and completed tasks
    final activeTasks =
        tp.tasks.where((t) => !t.completed).toList();
    final completedTasks =
        tp.tasks.where((t) => t.completed).toList();

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
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
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
                    child: const Icon(Icons.task_alt_rounded,
                        size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Tasks',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Hi, ${auth.user?.username ?? 'there'}!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Search toggle
                IconButton(
                  icon: Icon(
                    _showSearch
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchCtrl.clear();
                        tp.setSearchQuery('');
                      }
                    });
                  },
                  tooltip: 'Search tasks',
                ),
                // Theme toggle
                IconButton(
                  icon: Icon(
                    themeProvider.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
                ),
                // Logout
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (auth.user?.username ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'logout') auth.logout();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'user',
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.username ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text('Signed in',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sign Out',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Search Bar ──
            if (_showSearch)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: theme.colorScheme.primary),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                tp.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor:
                          theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => tp.setSearchQuery(v),
                  ),
                ),
              ),

            // ── Filter Bar ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: FilterBar(),
              ),
            ),

            // ── Stats Row ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${activeTasks.length} active',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (completedTasks.isNotEmpty) ...[
                      Text(
                        '  ·  ${completedTasks.length} completed',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${tp.tasks.length} total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Loading ──
            if (tp.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),

            // ── Empty ──
            if (!tp.loading && tp.tasks.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: tp.searchQuery.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.task_alt_rounded,
                  title: tp.searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No tasks yet',
                  subtitle: tp.searchQuery.isNotEmpty
                      ? 'Try a different search query'
                      : 'Tap the + button to create your first task',
                ),
              ),

            // ── Active Tasks ──
            if (!tp.loading && activeTasks.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      TaskCard(key: ValueKey(activeTasks[index].id), task: activeTasks[index]),
                  childCount: activeTasks.length,
                ),
              ),

            // ── Completed Section ──
            if (!tp.loading && completedTasks.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3)),
                      const SizedBox(width: 8),
                      Text(
                        'Completed (${completedTasks.length})',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      TaskCard(key: ValueKey(completedTasks[index].id), task: completedTasks[index]),
                  childCount: completedTasks.length,
                ),
              ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
