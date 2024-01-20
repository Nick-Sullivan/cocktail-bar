import 'package:flutter/material.dart';
import 'package:my_app/model/instruction_ingredient.dart';

enum Stage {
  crush,
  shake,
  pour,
  decorate,
  // stir,
  // blend,
  // glass,
  delete,
}

class RecipeStage {
  String id;
  Stage stage;
  String instructions;
  List<InstructionIngredient> instructionIngredients;

  RecipeStage(this.id, {
    this.stage = Stage.shake,
    this.instructions = '',
    this.instructionIngredients = const [],
  });

  factory RecipeStage.fromJson(Map<String, dynamic> map){
    List<InstructionIngredient> ingredients = [];
    for (var ingredientsJson in map['instructionIngredients']){
      var ingredient = InstructionIngredient.fromJson(ingredientsJson);
      ingredients.add(ingredient);
    }
    return RecipeStage(
      map['id'],
      stage: Stage.values.byName(map['stage']),
      instructions: map['instructions'],
      instructionIngredients: ingredients,
    );
  }

  factory RecipeStage.from(RecipeStage recipeStage){
    return RecipeStage.fromJson(recipeStage.toJson());
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> ingredientsJson = [];
    for (var ingredient in instructionIngredients){
      ingredientsJson.add(ingredient.toJson());
    }
    return {
      'id': id,
      'stage': stage.name,
      'instructions': instructions,
      'instructionIngredients': ingredientsJson,
    };
  }

}


Map<Stage, AssetImage> stageImages = {
  Stage.crush: const AssetImage('assets/blend.png'),
  // Stage.stir: const AssetImage('assets/stir.png'),
  Stage.shake: const AssetImage('assets/cocktail-shaker.png'),
  Stage.pour: const AssetImage('assets/drink.png'),
  Stage.decorate: const AssetImage('assets/umbrella.png'),
  // Stage.blend: const AssetImage('assets/blend.png'),
  // Stage.glass: const AssetImage('assets/glass.png'),
  Stage.delete: const AssetImage('assets/delete.png'),
};

Map<Stage, Widget> stageImagesWithText = {
  Stage.crush: overlayImage(stageImages[Stage.crush]!, Stage.crush.name),
  Stage.shake: overlayImage(stageImages[Stage.shake]!, Stage.shake.name),
  Stage.pour: overlayImage(stageImages[Stage.pour]!, Stage.pour.name),
  Stage.decorate: overlayImage(stageImages[Stage.decorate]!, Stage.decorate.name),
  // Stage.blend: overlayImage(stageImages[Stage.blend]!, Stage.blend.name),
  // Stage.stir: overlayImage(stageImages[Stage.stir]!, Stage.stir.name),
  // Stage.glass: overlayImage(stageImages[Stage.glass]!, Stage.glass.name),
  Stage.delete: overlayImage(stageImages[Stage.delete]!, Stage.delete.name),
};

Widget overlayImage(AssetImage image, String text){
  return Stack(
    children: [
      Image(
        image: image,
        color: const Color.fromRGBO(255, 255, 255, 0.5),
        colorBlendMode: BlendMode.modulate,
      ),
      Positioned.fill(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.white70
            ),
          ),
        )
      ),
      Positioned.fill(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.purple[400],
            ),
          ),
        )
      ),
    ],
  );
}
  