

import 'package:my_app/model/recipe_stage.dart';

class Recipe {
  String id;
  String name;
  List<RecipeStage> stages;
  String comment;
  double rating;

  Recipe(this.id, {this.name = '', this.stages = const [], this.comment = '', this.rating = 0});

  factory Recipe.fromJson(Map<String, dynamic> map){
    List<RecipeStage> stages = [];
    for (var stageJson in map['stages']){
      var stage = RecipeStage.fromJson(stageJson);
      stages.add(stage);
    }
    return Recipe(
      map['id'],
      name: map['name'],
      stages: stages,
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  factory Recipe.from(Recipe recipe){
    return Recipe.fromJson(recipe.toJson());
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> stagesJson = [];
    for (var stage in stages){
      stagesJson.add(stage.toJson());
    }
    return {
      'id': id,
      'name': name,
      'stages': stagesJson,
      'comment': comment,
      'rating': rating,
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
