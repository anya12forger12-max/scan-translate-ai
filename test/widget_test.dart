import 'package:flutter_test/flutter_test.dart';

import 'package:scan_translate_ai/features/translation/domain/entities/translation_result.dart';

void main() {
  test('supported languages contain core codes', () {
    final codes = Language.supported.map((l) => l.code).toSet();
    expect(codes, contains('en'));
    expect(codes, contains('es'));
    expect(codes, contains('hi'));
    expect(codes.length, greaterThanOrEqualTo(30));
  });
}
