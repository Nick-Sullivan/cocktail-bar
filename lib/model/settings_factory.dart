import 'dart:convert';

import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/exceptions.dart';
import 'package:my_app/model/settings.dart';

class SettingsFactory {
  static final String className = (Settings).toString();
  final DatabaseInteractor database;

  SettingsFactory(this.database);

  Future init() async {
    await database.init();
  }

  Future save(Settings settings) async {
    database.write(className, 'id', json.encode(settings.toJson()));
    return settings;
  }
  
  Settings get() {
    try {
      String value = database.read(className, 'id');
      return Settings.fromJson(jsonDecode(value));
    } on KeyNotFoundException catch (_) {
      return Settings();
    }
  }

}
