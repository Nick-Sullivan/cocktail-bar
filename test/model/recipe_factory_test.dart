import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/recipe.dart';
import 'package:my_app/model/recipe_factory.dart';

import 'recipe_factory_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DatabaseInteractor>()])
void main() {

  group('RecipeFactory', () {

    test('Init', () async {
      var db = MockDatabaseInteractor();
   
      var factory = RecipeFactory(db);
      await factory.init();

      verify(db.init());
    });

    test('Save', () async {
      var db = MockDatabaseInteractor();
      var recipe = Recipe('id');
      var encoded = json.encode(recipe.toJson());

      var factory = RecipeFactory(db);
      var result = await factory.save(recipe);

      verify(db.write('Recipe', 'id', encoded));
      expect(result, recipe);
    });

    test('Get list', () async {
      var db = MockDatabaseInteractor();
      var recipes = [
        Recipe('idB', name: 'B'),
        Recipe('idA', name: 'A'),
      ];
      var recipesJson = recipes.map((i) => i.toJson()).toList();
      var recipesEncoded = recipesJson.map((i) => json.encode(i)).toList();

      when(db.readList('Recipe'))
        .thenReturn(recipesEncoded);

      var factory = RecipeFactory(db);
      var result = factory.getList();

      expect(result[0].id, 'idA');
      expect(result[0].name, 'A');
      expect(result[1].id, 'idB');
      expect(result[1].name, 'B');
    });

    test('Get map', () async {
      var db = MockDatabaseInteractor();
      var recipes = [
        Recipe('idB', name: 'B'),
        Recipe('idA', name: 'A'),
      ];
      var recipesJson = recipes.map((i) => i.toJson()).toList();
      var recipesEncoded = recipesJson.map((i) => json.encode(i)).toList();

      when(db.readList('Recipe'))
        .thenReturn(recipesEncoded);

      var factory = RecipeFactory(db);
      var result = factory.getMap();

      expect(result['idA']!.name, 'A');
      expect(result['idB']!.name, 'B');
    });

    test('Delete', () async {
      var db = MockDatabaseInteractor();
   
      var factory = RecipeFactory(db);
      await factory.delete('id');

      verify(db.delete('Recipe', 'id'));
    });

  });
}

