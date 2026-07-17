enum BarcodeFormatType {
  qr,
  upcA,
  upcE,
  ean8,
  ean13,
  code39,
  code93,
  code128,
  codabar,
  itf,
  pdf417,
  dataMatrix,
  aztec,
  gs1,
  isbn,
  issn,
  unknown;

  String get displayName {
    return switch (this) {
      BarcodeFormatType.qr => 'QR Code',
      BarcodeFormatType.upcA => 'UPC-A',
      BarcodeFormatType.upcE => 'UPC-E',
      BarcodeFormatType.ean8 => 'EAN-8',
      BarcodeFormatType.ean13 => 'EAN-13',
      BarcodeFormatType.code39 => 'Code 39',
      BarcodeFormatType.code93 => 'Code 93',
      BarcodeFormatType.code128 => 'Code 128',
      BarcodeFormatType.codabar => 'Codabar',
      BarcodeFormatType.itf => 'ITF',
      BarcodeFormatType.pdf417 => 'PDF417',
      BarcodeFormatType.dataMatrix => 'Data Matrix',
      BarcodeFormatType.aztec => 'Aztec',
      BarcodeFormatType.gs1 => 'GS1',
      BarcodeFormatType.isbn => 'ISBN',
      BarcodeFormatType.issn => 'ISSN',
      BarcodeFormatType.unknown => 'Unknown',
    };
  }
}
