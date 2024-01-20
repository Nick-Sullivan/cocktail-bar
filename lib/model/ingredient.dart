
import 'package:flutter/material.dart';

class Ingredient {
  String id;
  String name;
  Color color;
  bool isAlcoholic;
  bool isStocked;

  Ingredient(this.id, {
    this.name = "",
    this.color = Colors.red,
    this.isAlcoholic = true,
    this.isStocked = false,
  });

  factory Ingredient.fromJson(Map<String, dynamic> map){
    return Ingredient(
      map['id'],
      name: map['name'],
      color: map['color'] != null ? Color(map['color']) : Colors.red,
      isAlcoholic: map['isAlcoholic'] ?? true,
      isStocked: map['isStocked'] ?? false,
    );
  }

  factory Ingredient.from(Ingredient recipe){
    return Ingredient.fromJson(recipe.toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'isAlcoholic': isAlcoholic,
      'isStocked': isStocked,
    };
  }

  bool isValid() {
    return isValidName(name);
  }

  static bool isValidName(String? name) {
    return (
      name != null
      && name.isNotEmpty
    );
  }
}