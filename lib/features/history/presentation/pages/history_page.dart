import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override void initState() { super.initState(); Future.microtask(() => _load()); }

  Future<void> _load() async {
    ref.read(historyProvider.notifier).setLoading();
    (await ref.read(historyRepositoryProvider).getHistory()).fold(
      (f) => ref.read(historyProvider.notifier).setError(f.message),
      (items) => ref.read(historyProvider.notifier).setItems(items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hs = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History'), actions: [
        if (hs.items.isNotEmpty)
          IconButton(onPressed: () async {
            HapticUtils.warning();
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Clear History'), content: const Text('Are you sure?'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red)))],
            ));
            if (confirm == true) {
              (await ref.read(historyRepositoryProvider).clearHistory()).fold(
                (f) => ref.read(historyProvider.notifier).setError(f.message),
                (_) => ref.read(historyProvider.notifier).clear(),
              );
            }
          }, icon: const Icon(Icons.delete_sweep)),
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(hs),
      ),
    );
  }

  Widget _buildBody(HistoryState hs) {
    switch (hs.status) {
      case HistoryStatus.initial: return const SizedBox.shrink();
      case HistoryStatus.loading: return const LoadingDisplay(message: 'Loading history...');
      case HistoryStatus.error: return ErrorDisplay(message: hs.errorMessage!, actionLabel: 'Retry', onAction: _load);
      case HistoryStatus.success:
        if (hs.items.isEmpty) return const EmptyState(icon: Icons.history, title: 'No history yet', subtitle: 'Your scans and translations will appear here.');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hs.items.length,
          itemBuilder: (ctx, i) {
            final item = hs.items[i];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) {
                ref.read(historyProvider.notifier).removeItem(item.id);
                ref.read(historyRepositoryProvider).deleteItem(item.id);
              },
              child: HistoryCard(item: item),
            );
          },
        );
    }
  }
}
