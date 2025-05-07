import 'dart:convert';
import 'dart:io';

void main() async {
  final input = await stdin.transform(utf8.decoder).join();
  final events = LineSplitter.split(input)
      .map((line) => json.decode(line))
      .where((e) => e is Map)
      .toList();

  final testCases = <String, List<Map>>{};

  for (var e in events) {
    if (e['type'] == 'testDone') {
      final name = e['name'] ?? 'unknown';
      final status = e['result'] ?? 'unknown';
      final suite = e['suite'] ?? 'default';
      testCases.putIfAbsent(suite.toString(), () => []).add({
        'name': name,
        'status': status,
      });
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<testsuites>');

  testCases.forEach((suite, cases) {
    buffer.writeln('  <testsuite name="$suite" tests="${cases.length}">');
    for (var test in cases) {
      buffer.write('    <testcase name="${test['name']}">');
      if (test['status'] != 'success') {
        buffer.writeln('<failure message="${test['status']}"/>');
      }
      buffer.writeln('</testcase>');
    }
    buffer.writeln('  </testsuite>');
  });

  buffer.writeln('</testsuites>');
  print(buffer.toString());
}
