import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';
import 'dream_entry_screen.dart';

class JournalOverviewScreen extends StatefulWidget {
  static const routeName = '/journal-overview';

  const JournalOverviewScreen({super.key});

  @override
  State<JournalOverviewScreen> createState() => _JournalOverviewScreenState();
}

enum _JournalQuickFilter { lucid, nightmare, feelings }

class _JournalOverviewScreenState extends State<JournalOverviewScreen> {
  String? _selectedTag;
  final Set<_JournalQuickFilter> _quickFilters = {};

  List<DreamEntry> _applyFilters(List<DreamEntry> dreams) {
    final filteredByTag = _selectedTag == null
        ? dreams
        : dreams.where((dream) => dream.tags.contains(_selectedTag)).toList();

    if (_quickFilters.isEmpty) {
      return filteredByTag;
    }

    return filteredByTag.where((dream) {
      if (_quickFilters.contains(_JournalQuickFilter.lucid) && !dream.lucid) {
        return false;
      }
      if (_quickFilters.contains(_JournalQuickFilter.nightmare) && !dream.nightmare) {
        return false;
      }
      if (_quickFilters.contains(_JournalQuickFilter.feelings) && !dream.onlyFeelingsLog) {
        return false;
      }
      return true;
    }).toList();
  }

  Map<DateTime, List<DreamEntry>> _groupByDate(List<DreamEntry> dreams) {
    final grouped = <DateTime, List<DreamEntry>>{};
    for (final dream in dreams) {
      final day = DateTime(dream.createdAt.year, dream.createdAt.month, dream.createdAt.day);
      grouped.putIfAbsent(day, () => []).add(dream);
    }
    return grouped;
  }

  String _formatDay(DateTime day) => DateFormat('EEEE, MMM d, yyyy').format(day);

  String _quickFilterLabel(_JournalQuickFilter filter) {
    switch (filter) {
      case _JournalQuickFilter.lucid:
        return 'Lucid';
      case _JournalQuickFilter.nightmare:
        return 'Nightmares';
      case _JournalQuickFilter.feelings:
        return 'Feelings only';
    }
  }

  void _toggleQuickFilter(_JournalQuickFilter filter) {
    setState(() {
      if (_quickFilters.contains(filter)) {
        _quickFilters.remove(filter);
      } else {
        _quickFilters.add(filter);
      }
    });
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTag == tag) {
        _selectedTag = null;
      } else {
        _selectedTag = tag;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dreams = _applyFilters(appState.dreams);
    final grouped = _groupByDate(dreams);
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final tagCounts = appState.tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Stack(
      children: [
        DreamBackground(
          useSafeArea: false,
          child: const SizedBox.expand(),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Dream journal'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
            child: ListView(
              children: [
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Your dream archive',
                        subtitle: 'Browse every dream with quick filters and tags.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          StatChip(
                            label: 'total dreams',
                            value: '${appState.dreams.length}',
                            icon: Icons.library_books,
                          ),
                          StatChip(
                            label: 'lucid moments',
                            value: '${appState.lucidDreamCount}',
                            icon: Icons.auto_awesome,
                          ),
                          StatChip(
                            label: 'nightmares soothed',
                            value: '${appState.nightmareCount}',
                            icon: Icons.shield_moon,
                          ),
                          StatChip(
                            label: 'unique tags',
                            value: '${tagCounts.length}',
                            icon: Icons.sell,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (tagCounts.isNotEmpty)
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final entry in tagCounts)
                              ChoiceChip(
                                label: Text('${entry.key} · ${entry.value}'),
                                selected: _selectedTag == entry.key,
                                onSelected: (_) => _onTagSelected(entry.key),
                              ),
                            if (_selectedTag != null)
                              TextButton(
                                onPressed: () => _onTagSelected(_selectedTag!),
                                child: const Text('Clear tag filter'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final filter in _JournalQuickFilter.values)
                            FilterChip(
                              label: Text(_quickFilterLabel(filter)),
                              selected: _quickFilters.contains(filter),
                              onSelected: (_) => _toggleQuickFilter(filter),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (dreams.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: EmptyState(
                      title: 'No dreams match these filters',
                      subtitle: 'Capture tonight or reset the filters to explore earlier stories.',
                    ),
                  )
                else
                  ...[
                    for (final day in sortedDays)
                      FrostedCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDay(day),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < grouped[day]!.length; i++)
                              _DreamJournalEntry(
                                dream: grouped[day]![i],
                                showDivider: i != grouped[day]!.length - 1,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DreamEntryScreen(existingDream: grouped[day]![i]),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DreamJournalEntry extends StatelessWidget {
  const _DreamJournalEntry({
    required this.dream,
    required this.onTap,
    required this.showDivider,
  });

  final DreamEntry dream;
  final VoidCallback onTap;
  final bool showDivider;

  List<Widget> _buildBadges(BuildContext context) {
    final badges = <Widget>[];
    if (dream.lucid) {
      badges.add(_Badge(label: 'Lucid', icon: Icons.auto_awesome));
    }
    if (dream.nightmare) {
      badges.add(_Badge(label: 'Nightmare', icon: Icons.shield_moon));
    }
    if (dream.onlyFeelingsLog) {
      badges.add(_Badge(label: 'Feelings', icon: Icons.favorite));
    }
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dream.title.isNotEmpty ? dream.title : 'Untitled dream',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            if (dream.transcription.isNotEmpty)
              Text(
                dream.transcription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else if (dream.fragments.isNotEmpty)
              Text(
                dream.fragments
                    .map((fragment) => fragment.value)
                    .where((value) => value.isNotEmpty)
                    .join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._buildBadges(context),
                for (final tag in dream.tags)
                  Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat.jm().format(dream.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            if (showDivider) const Divider(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
