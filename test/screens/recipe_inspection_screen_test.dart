
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:my_app/model/ingredient.dart';
// import 'package:my_app/model/recipe_step.dart';
// import 'package:my_app/model/recipe_unit.dart';
// import 'package:my_app/screens/recipe_inspection_screen.dart';


// Widget createWidgetForTesting(Widget child){
//   return MaterialApp(
//     home: child,
//   );
// }

// void main() {

//   testWidgets('StepWidget', (tester) async {
//     await tester.pumpWidget(createWidgetForTesting(StepWidget(
//       recipeStep: RecipeStep(
//         'id', 
//         'ingredientId', 
//         unit: Unit.shots,
//         amount: 1,
//       ),
//       ingredients: [
//         Ingredient('ingredientId', name: 'ingredientName'),
//       ],
//     )));

//     final nameFinder = find.text('1.0 shots ingredientName');

//     expect(nameFinder, findsOneWidget);
//   });

// }

