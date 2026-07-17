import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  final String id;
  final String scanType;
  final String formatType;
  final String rawValue;
  final String? displayValue;
  final DateTime scannedAt;
  final bool isFavorite;

  const HistoryItem({
    required this.id,
    required this.scanType,
    required this.formatType,
    required this.rawValue,
    this.displayValue,
    required this.scannedAt,
    this.isFavorite = false,
  });

  HistoryItem copyWith({
    String? id,
    String? scanType,
    String? formatType,
    String? rawValue,
    String? displayValue,
    DateTime? scannedAt,
    bool? isFavorite,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      scanType: scanType ?? this.scanType,
      formatType: formatType ?? this.formatType,
      rawValue: rawValue ?? this.rawValue,
      displayValue: displayValue ?? this.displayValue,
      scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        scanType,
        formatType,
        rawValue,
        displayValue,
        scannedAt,
        isFavorite,
      ];
}
