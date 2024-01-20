import 'dart:convert';
import 'recipe.dart';

import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/recipe_step.dart';

class RecipeFactory {
  static final String className = (Recipe).toString();
  static final String stepsPrefix = (RecipeStep).toString();
  final DatabaseInteractor database;

  RecipeFactory(this.database);

  Future init() async {
    await database.init();
  }

  Future save(Recipe recipe) async {
    database.write(className, recipe.id, json.encode(recipe.toJson()));
    return recipe;
  }
  
  Recipe get(String id) {
    String value = database.read(className, id);
    return Recipe.fromJson(jsonDecode(value));
  }

  List<Recipe> getList() {
    List<String> values = database.readList(className);
    var recipes = values.map((v) => Recipe.fromJson(json.decode(v))).toList();
    recipes.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
    return recipes;
  }

  Map<String, Recipe> getMap() {
    var ingredients = getList();
    return {for (var i in ingredients) i.id: i};
  }

  Future delete(String id) {
    return database.delete(className, id);
  }

}
