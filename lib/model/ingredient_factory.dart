import 'dart:convert';
import 'ingredient.dart';

import 'package:my_app/data_access/database_interactor.dart';

class IngredientFactory {
  static final String className = (Ingredient).toString();
  final DatabaseInteractor database;

  IngredientFactory(this.database);

  Future init() async {
    await database.init();
  }

  Future<Ingredient> save(Ingredient ingredient) async{
    database.write(className, ingredient.id, json.encode(ingredient.toJson()));
    return ingredient;
  }
  
  List<Ingredient> getList() {
    List<String> values = database.readList(className);
    var ingredients = values.map((v) => Ingredient.fromJson(json.decode(v))).toList();
    ingredients.sort((a, b) => a.name.compareTo(b.name));
    return ingredients;
  }

  Map<String, Ingredient> getMap() {
    var ingredients = getList();
    return {for (var i in ingredients) i.id: i};
  }

  Future delete(String id) {
    return database.delete(className, id);
  }

}
