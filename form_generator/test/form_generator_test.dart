import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_generator/src/form_generator.dart';

void main() {
  const MethodChannel channel = MethodChannel('form_generator');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
