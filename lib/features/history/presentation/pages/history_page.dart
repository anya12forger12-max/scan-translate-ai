import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../domain/entities/history_item.dart';
import '../providers/history_provider.dart';
import '../widgets/history_filter.dart';
import '../widgets/history_list_item.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final historyNotifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (historyState.items.isNotEmpty)
            Semantics(
              label: 'Clear all history',
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All History?'),
                      content: const Text(
                        'This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    HapticUtils.mediumImpact();
                    historyNotifier.clearAll();
                  }
                },
                tooltip: 'Clear all history',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          HistoryFilter(
            selectedType: historyState.typeFilter,
            onTypeChanged: (type) => historyNotifier.setTypeFilter(type),
          ),
          const SizedBox(height: 8),
          if (historyState.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
                label: 'Search scan history',
                child: TextField(
                  onChanged: (query) => historyNotifier.setSearchQuery(query),
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: historyState.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => historyNotifier.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildContent(historyState, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HistoryState state, WidgetRef ref) {
    if (state.status == HistoryStatus.loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SkeletonLoader(height: 80, borderRadius: 16),
        ),
      );
    }

    if (state.status == HistoryStatus.error) {
      return ErrorDisplay(
        message: state.errorMessage ?? 'Failed to load history.',
        actionLabel: 'Retry',
        onAction: () => ref.read(historyProvider.notifier).setLoading(),
      );
    }

    final items = state.searchQuery.isNotEmpty || state.typeFilter != null
        ? state.filteredItems
        : state.items;

    if (items.isEmpty) {
      return EmptyState(
        title: state.searchQuery.isNotEmpty
            ? 'No Results Found'
            : 'No Scan History Yet',
        subtitle: state.searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Your scanned codes will appear here',
        icon: Icons.history_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(historyProvider.notifier).setLoading();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return HistoryListItem(
            item: item,
            onTap: () {
              _showDetailDialog(context, item);
            },
            onToggleFavorite: () {
              ref.read(historyProvider.notifier).toggleFavorite(item.id);
            },
            onDelete: () {
              ref.read(historyProvider.notifier).removeItem(item.id);
            },
          );
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${item.scanType.toUpperCase()} Result',
                  style: AppTypography.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                item.rawValue,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Share.share(item.rawValue);
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.favoriteColor,
                  ),
                  label: Text(item.isFavorite ? 'Favorited' : 'Favorite'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
