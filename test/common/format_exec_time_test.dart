import 'package:flutter_test/flutter_test.dart';
import 'package:recorod_to_text/common/int_extension.dart';

void main() {
  test('1秒未満の場合はミリ秒フォーマットになることを確認する', () {
    expect(1.formatExecTime(), '1 ms');
    expect(999.formatExecTime(), '999 ms');
  });

  test('1秒以上60秒以下の場合は秒のフォーマットになることを確認する', () {
    expect(1000.formatExecTime(), '1.000s');
    expect(59999.formatExecTime(), '59.999s');
    expect(60000.formatExecTime(), '60.000s');
  });

  test('60秒より大きいの場合は分と秒のフォーマットになることを確認する', () {
    expect(60001.formatExecTime(), '1m0s');
    expect(60100.formatExecTime(), '1m0s');
    expect(121000.formatExecTime(), '2m1s');
    expect(61000.formatExecTime(), '1m1s');
  });
}
