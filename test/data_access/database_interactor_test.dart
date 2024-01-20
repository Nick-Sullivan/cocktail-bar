import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/data_access/database_interactor.dart';

// @GenerateMocks([SharedPreferences])
void main() {
  test('Unique key', () {
    var key = createUniqueKey();
    expect(key[0], '[');
    expect(key[key.length-1], ']');
  });

  group('DatabaseInteractor', () {

    test('Write and read', () async {     
      var db = DatabaseInteractor();
      await db.init();

      await db.write('ClassName', '[123]', 'value');
      var result = db.read('ClassName', '[123]');

      expect(result, 'value');
    });

    test('Delete', () async {
      SharedPreferences.setMockInitialValues({
        'ClassName[123]': 'value',
      });

      var db = DatabaseInteractor();
      await db.init();

      await db.delete('ClassName', '[123]');
      
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), <dynamic>{});
    });

    test('Read list', () async {
      SharedPreferences.setMockInitialValues({
        'prefix[123]': 'value',
      });

      var db = DatabaseInteractor();
      await db.init();

      var result = db.readList('prefix');

      expect(result, ['value']);
    });

    test('Export', () async {
      SharedPreferences.setMockInitialValues({
        'prefix[123]': 'value',
      });

      var db = DatabaseInteractor();
      await db.init();

      var result = db.export();

      expect(result, '{"prefix[123]":"value"}');
    });

    test('Import and export', () async {
      SharedPreferences.setMockInitialValues({
        'something': 'else',
      });

      var db = DatabaseInteractor();
      await db.init();

      await db.import('{"prefix[123]":"value"}');
      var result = db.export();

      expect(result, '{"prefix[123]":"value"}');
    });
  });
}

