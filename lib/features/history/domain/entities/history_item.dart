import 'package:equatable/equatable.dart';

enum HistoryItemType { scan, ocr, translation }

class HistoryItem extends Equatable {
  final String id;
  final HistoryItemType type;
  final String title;
  final String subtitle;
  final String? details;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const HistoryItem({required this.id, required this.type, required this.title, required this.subtitle,
    this.details, required this.timestamp, this.metadata});

  HistoryItem copyWith({String? id, HistoryItemType? type, String? title, String? subtitle, String? details,
    DateTime? timestamp, Map<String, dynamic>? metadata}) =>
    HistoryItem(id: id ?? this.id, type: type ?? this.type, title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle, details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp, metadata: metadata ?? this.metadata);

  @override List<Object?> get props => [id, type, title, subtitle, details, timestamp, metadata];
}
