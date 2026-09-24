enum BarcodeFormatType {
  qr, upcA, upcE, ean8, ean13, code39, code93, code128, codabar, itf,
  pdf417, dataMatrix, aztec, gs1, isbn, issn, unknown;
  String get displayName => name.toUpperCase().replaceAll('_', '-');
}
