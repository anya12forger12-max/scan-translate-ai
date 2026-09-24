import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryState {
  final HistoryStatus status;
  final List<HistoryItem> items;
  final String? errorMessage;
  const HistoryState({this.status = HistoryStatus.initial, this.items = const [], this.errorMessage});
  HistoryState copyWith({HistoryStatus? status, List<HistoryItem>? items, String? errorMessage}) =>
    HistoryState(status: status ?? this.status, items: items ?? this.items, errorMessage: errorMessage ?? this.errorMessage);
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());
  void setLoading() => state = state.copyWith(status: HistoryStatus.loading, errorMessage: null);
  void setItems(List<HistoryItem> items) => state = state.copyWith(status: HistoryStatus.success, items: items);
  void addItem(HistoryItem item) => state = state.copyWith(items: [item, ...state.items]);
  void removeItem(String id) => state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
  void clear() => state = state.copyWith(items: []);
  void setError(String m) => state = state.copyWith(status: HistoryStatus.error, errorMessage: m);
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) => HistoryNotifier());
