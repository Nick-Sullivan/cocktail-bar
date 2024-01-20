import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:my_app/model/ingredient.dart';
import 'package:my_app/model/ingredient_factory.dart';
import 'package:my_app/data_access/database_interactor.dart';

import 'ingredient_factory_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DatabaseInteractor>()])
void main() {

  group('IngredientFactory', () {

    test('Init', () async {
      var db = MockDatabaseInteractor();
   
      var factory = IngredientFactory(db);
      await factory.init();

      verify(db.init());
    });

    test('Save', () async {
      var db = MockDatabaseInteractor();
      var ingredient = Ingredient('id');
      var encoded = json.encode(ingredient.toJson());

      var factory = IngredientFactory(db);
      var result = await factory.save(ingredient);

      verify(db.write('Ingredient', 'id', encoded));
      expect(result, ingredient);
    });

    test('Get list', () async {
      var db = MockDatabaseInteractor();
      var ingredients = [
        Ingredient('idB', name: 'B'),
        Ingredient('idA', name: 'A'),
      ];
      var ingredientsJson = ingredients.map((i) => i.toJson()).toList();
      var ingredientsEncoded = ingredientsJson.map((i) => json.encode(i)).toList();

      when(db.readList('Ingredient'))
        .thenReturn(ingredientsEncoded);

      var factory = IngredientFactory(db);
      var result = factory.getList();

      expect(result[0].id, 'idA');
      expect(result[0].name, 'A');
      expect(result[1].id, 'idB');
      expect(result[1].name, 'B');
    });

    test('Get map', () async {
      var db = MockDatabaseInteractor();
      var ingredients = [
        Ingredient('idB', name: 'B'),
        Ingredient('idA', name: 'A'),
      ];
      var ingredientsJson = ingredients.map((i) => i.toJson()).toList();
      var ingredientsEncoded = ingredientsJson.map((i) => json.encode(i)).toList();

      when(db.readList('Ingredient'))
        .thenReturn(ingredientsEncoded);

      var factory = IngredientFactory(db);
      var result = factory.getMap();

      expect(result['idA']!.name, 'A');
      expect(result['idB']!.name, 'B');
    });

    test('Delete', () async {
      var db = MockDatabaseInteractor();
   
      var factory = IngredientFactory(db);
      await factory.delete('id');

      verify(db.delete('Ingredient', 'id'));
    });

  });
}

