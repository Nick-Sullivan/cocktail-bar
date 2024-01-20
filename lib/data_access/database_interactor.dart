import 'dart:convert';

import 'package:my_app/model/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class DatabaseInteractor {
  static late SharedPreferences prefs;
  static const String counterKey = 'Counter';

  DatabaseInteractor();

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future write(String className, String id, String encodedJson) {
    var key = getKey(className, id);
    return prefs.setString(key, encodedJson);
  }

  String read(String className, String id){
    var key = getKey(className, id);
    if (!prefs.containsKey(key)) {
      throw KeyNotFoundException(key);
    }
    return prefs.getString(key)!;
  }

  Future delete(String className, String id) {
    var key = getKey(className, id);
    return prefs.remove(key);
  }

  List<String> readList(String prefix) {
    List<String> values = [];

    Set<String> keys = prefs.getKeys();
    for (final key in keys){
      if (!key.startsWith(prefix)) {
        continue;
      }
      var nextChar = key[prefix.length];
      // if (!isDigit(nextChar)){
      if (nextChar != '['){
        continue;
      }
      values.add(prefs.getString(key)!);
    }

    return values;
  }

  String export(){
    var keys = prefs.getKeys();
    var result = <String, String>{};
    for (var key in keys){
      result[key] = key == counterKey
        ? prefs.getInt(key).toString()
        : prefs.getString(key)!;
    }
    return json.encode(result);
  }

  Future import(String data) async {
    var jsonData = json.decode(data);

    await prefs.clear();

    for (var key in jsonData.keys){
      if (key == counterKey){
        prefs.setInt(key, int.parse(jsonData[key]));
      } else {
        prefs.setString(key, jsonData[key]);
      }
    }
  }

  // static bool isDigit(String s) {
  //   return "0".compareTo(s) <= 0 
  //     && "9".compareTo(s) >= 0;
  // }

  static String getKey(String className, String id){
    return className + id;
  }

  // Future<int> createId() {
  //   var counter = prefs.getInt(counterKey) ?? 0;
  //   return prefs.setInt(counterKey, counter+1).then((_) => counter);
  // }

}


String createUniqueKey(){
  return '[${const Uuid().v4()}]';
}