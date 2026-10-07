import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryState {
  final HistoryStatus status;
  final List<HistoryItem> items;
  final List<HistoryItem> filteredItems;
  final String? errorMessage;
  final String searchQuery;
  final String? typeFilter;
  final bool favoritesOnly;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.filteredItems = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.typeFilter,
    this.favoritesOnly = false,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryItem>? items,
    List<HistoryItem>? filteredItems,
    String? errorMessage,
    String? searchQuery,
    String? typeFilter,
    bool? favoritesOnly,
    bool clearError = false,
    bool clearTypeFilter = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(const HistoryState());

  Future<void> loadHistory() async {
    state = state.copyWith(status: HistoryStatus.loading, clearError: true);
    final result = await _repository.getHistory();
    if (!mounted) return;
    result.fold(
      (failure) => setError(failure.message),
      (items) => setItems(items),
    );
  }

  void setItems(List<HistoryItem> items) {
    state = state.copyWith(
      status: HistoryStatus.success,
      items: items,
      filteredItems: _filterItems(
        items,
        state.searchQuery,
        state.typeFilter,
        state.favoritesOnly,
      ),
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
      filteredItems: _filterItems(
        state.items,
        query,
        state.typeFilter,
        state.favoritesOnly,
      ),
    );
  }

  void setTypeFilter(String? type) {
    state = state.copyWith(
      typeFilter: type,
      clearTypeFilter: type == null,
      filteredItems: _filterItems(
        state.items,
        state.searchQuery,
        type,
        state.favoritesOnly,
      ),
    );
  }

  void setFavoritesOnly(bool value) {
    state = state.copyWith(
      favoritesOnly: value,
      filteredItems: _filterItems(
        state.items,
        state.searchQuery,
        state.typeFilter,
        value,
      ),
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
      filteredItems: _filterItems(
        items,
        state.searchQuery,
        state.typeFilter,
        state.favoritesOnly,
      ),
    );
  }

  void removeItem(String id) {
    final items = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(
      items: items,
      filteredItems: _filterItems(
        items,
        state.searchQuery,
        state.typeFilter,
        state.favoritesOnly,
      ),
    );
  }

  void clearAll() {
    state = const HistoryState();
  }

  List<HistoryItem> _filterItems(
    List<HistoryItem> items,
    String query,
    String? type,
    bool favoritesOnly,
  ) {
    var filtered = items;

    if (favoritesOnly) {
      filtered = filtered.where((item) => item.isFavorite).toList();
    }

    if (type != null) {
      filtered = filtered.where((item) => item.scanType == type).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (item) => item.rawValue.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});
