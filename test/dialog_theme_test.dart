import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/theme/app_theme.dart';

void main() {
  test('dialog titles are readable on the white dialog', () {
    final dialog = AppTheme.lightTheme.dialogTheme;
    expect(dialog.backgroundColor, Colors.white);
    expect(dialog.titleTextStyle?.color, isNot(Colors.white));
    expect(dialog.contentTextStyle?.color, isNot(Colors.white));
  });
}
