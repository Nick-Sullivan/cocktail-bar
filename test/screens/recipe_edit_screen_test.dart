
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/model/ingredient.dart';
import 'package:my_app/model/instruction_ingredient.dart';
import 'package:my_app/model/recipe.dart';
import 'package:my_app/screens/recipe_edit_screen.dart';

void assertEqual(List<InstructionIngredient> expected, List<InstructionIngredient> actual){
  expect(expected.length, actual.length);
  for (int i = 0; i<expected.length; i++){
    expect(expected[i].ingredientId, actual[i].ingredientId);
    expect(expected[i].startIndex, actual[i].startIndex);
    expect(expected[i].endIndex, actual[i].endIndex);
  }
}

void main() {

  group('RecipeEditScreen', () {
    var obj = RecipeEditScreen(
      initialRecipe: Recipe('A'),
      ingredients: [
        Ingredient('G', name: 'Grenadine'),
        Ingredient('L', name: 'Lime'),
        Ingredient('LR', name: 'Lime rind'),
        Ingredient('O', name: 'Orange'),
        Ingredient('CO', name: 'Chocolate orange'),
        Ingredient('CC', name: 'Cocktail cherry'),
        Ingredient('CR', name: 'Cherry Ripe'),
        Ingredient('I', name: 'Ice'),
      ],
      onRecipeSaved: (_) {},
    );

    test('Simple detection', () async {
      var instructions = "1 teaspoon grenadine";
      var expected = [
        InstructionIngredient('G', 11, 20),
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Two detections', () async {
      var instructions = "1 teaspoon grenadine, grenadine";
      var expected = [
        InstructionIngredient('G', 11, 20),
        InstructionIngredient('G', 22, 31),
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Overlapping detections', () async {
      var instructions = "1 lime rind";
      var expected = [
        InstructionIngredient('LR', 2, 11),
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Opposite overlap', () async {
      var instructions = "1 chocolate orange";
      var expected = [
        InstructionIngredient('CO', 2, 18),
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Double overlap', () async {
      var instructions = "Cocktail cherry ripe";
      var expected = [
        InstructionIngredient('CC', 0, 15),
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Ingredient inside a word', () async {
      var instructions = "Lemon juice";
      var expected = <InstructionIngredient>[];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });

    test('Plural', () async {
      var instructions = "2 Limes";
      var expected = <InstructionIngredient>[
        InstructionIngredient('L', 2, 6)
      ];

      var response = obj.detectIngredients(instructions);
      assertEqual(expected, response);
    });


  });
}

