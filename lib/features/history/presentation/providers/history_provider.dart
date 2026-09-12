import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryState {
  final HistoryStatus status;
  final List<HistoryItem> items;
  final List<HistoryItem> filteredItems;
  final String? errorMessage;
  final String searchQuery;
  final String? typeFilter;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.filteredItems = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.typeFilter,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryItem>? items,
    List<HistoryItem>? filteredItems,
    String? errorMessage,
    String? searchQuery,
    String? typeFilter,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  void setItems(List<HistoryItem> items) {
    state = state.copyWith(
      status: HistoryStatus.success,
      items: items,
      filteredItems: _filterItems(items, state.searchQuery, state.typeFilter),
    );
  }

  void setLoading() {
    state = state.copyWith(status: HistoryStatus.loading);
  }

  void setError(String message) {
    state = state.copyWith(status: HistoryStatus.error, errorMessage: message);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredItems: _filterItems(state.items, query, state.typeFilter),
    );
  }

  void setTypeFilter(String? type) {
    state = state.copyWith(
      typeFilter: type,
      filteredItems: _filterItems(state.items, state.searchQuery, type),
    );
  }

  void toggleFavorite(String id) {
    final items = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(isFavorite: !item.isFavorite);
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: items,
      filteredItems: _filterItems(items, state.searchQuery, state.typeFilter),
    );
  }

  void removeItem(String id) {
    final items = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(
      items: items,
      filteredItems: _filterItems(items, state.searchQuery, state.typeFilter),
    );
  }

  void clearAll() {
    state = const HistoryState();
  }

  List<HistoryItem> _filterItems(
    List<HistoryItem> items,
    String query,
    String? type,
  ) {
    var filtered = items;

    if (type != null) {
      filtered = filtered.where((item) => item.scanType == type).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.rawValue.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return filtered;
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});
