
import 'package:my_app/model/recipe_unit.dart';

class RecipeStep {
  String id;
  String ingredientId;
  double amount;
  Unit unit;

  RecipeStep(this.id, this.ingredientId, {
    this.amount = 0,
    this.unit = Unit.shots,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> map){
    return RecipeStep(
      map['id'],
      map['ingredientId'],
      amount: map['amount'],
      unit: Unit.values.byName(map['unit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientId': ingredientId,
      'amount': amount,
      'unit': unit.name,
    };
  }

  String amountString() {
    if (amount == 0) return '';
    var rounded = amount.round();
    if (rounded == amount) return rounded.toString();
    return amount.toString();
  }
}
