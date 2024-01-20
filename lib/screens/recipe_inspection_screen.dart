import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/model/ingredient.dart';
import 'package:my_app/model/recipe.dart';
import 'package:my_app/model/recipe_stage.dart';
import 'package:my_app/model/recipe_step.dart';
import 'package:my_app/model/recipe_unit.dart';
import 'package:my_app/screens/recipe_edit_screen.dart';


class RecipeInspectionScreen extends StatefulWidget {
  final Recipe initialRecipe;
  final List<Ingredient> ingredients;
  final Function(String) onRecipeDeleted;
  final Function(Recipe) onRecipeSaved;
  
  const RecipeInspectionScreen({
    super.key,
    required this.initialRecipe,
    required this.ingredients,
    required this.onRecipeDeleted,
    required this.onRecipeSaved,
  });

  @override
  State<RecipeInspectionScreen> createState() => _RecipeInspectionScreenState();
}

class _RecipeInspectionScreenState extends State<RecipeInspectionScreen> {
  late Recipe recipe;

  @override
  void initState() {
    recipe = Recipe.from(widget.initialRecipe);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: buildCommentBox()),
            ],
          ),
          Expanded(
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: buildRecipeTiles()
              ).toList()
            ),
          ),
        ]
      ),
    );
  }

  AppBar buildAppBar(BuildContext context){
    return AppBar(
      title: Text(widget.initialRecipe.name),
      actions: [
        buildStarRating(),
        PopupMenuButton(
          itemBuilder: (_) {
            return [
              const PopupMenuItem(
                value: 0,
                child: Text("Edit"),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text("Delete"),
              ),
            ];
          },
          onSelected: ((value) {
            if (value == 0){
              editRecipe(context);
            }
            if (value == 1){
              deleteRecipeRequest(context);
            }
          }),
        )
      ]
    );
  }

  Widget buildStarRating() {
    return RatingBarIndicator(
      rating: recipe.rating,
      itemCount: 5,
      itemSize: 15,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.purple,
      ),
    );
  }

  Widget buildCommentBox(){
    if (recipe.comment.isEmpty){
      return const SizedBox(width: 0, height: 0);
    }
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        recipe.comment,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  List<ListTile> buildRecipeTiles(){
    List<ListTile> tiles = [];
    for (final stage in recipe.stages){
      tiles.add(buildStage(stage));
    }
    return tiles;
  }

  ListTile buildStage(RecipeStage recipeStage){
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStageHeader(recipeStage),
          buildInstruction(recipeStage),
        ],
      )
    );
  }

  Widget buildStageHeader(RecipeStage recipeStage){
    return Row(
      children: [
        SizedBox(
          height: 50,
          child: Image(image: stageImages[recipeStage.stage]!)
        ),
        Text(
          recipeStage.stage.name,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black
          )
        )
      ]
    );
  }

  Widget buildInstruction(RecipeStage recipeStage) {
    var defaultStyle = const TextStyle(color: Colors.black);
    var instructionSubstring = recipeStage.instructions;
    var spans = <TextSpan>[];
    for (var instructionIngredient in recipeStage.instructionIngredients.reversed){
      var ingredient = widget.ingredients.singleWhere((i) => i.id == instructionIngredient.ingredientId);
      spans.add(TextSpan(
        text: instructionSubstring.substring(instructionIngredient.endIndex),
        style: defaultStyle,
      ));
      spans.add(TextSpan(
        text: instructionSubstring.substring(instructionIngredient.startIndex, instructionIngredient.endIndex),
        style: TextStyle(color: ingredient.color, fontWeight: FontWeight.bold),
      ));
      instructionSubstring = instructionSubstring.substring(0, instructionIngredient.startIndex);
    }
    spans.add(TextSpan(text: instructionSubstring, style: defaultStyle));
    spans = spans.reversed.toList();
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  void editRecipe(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeEditScreen(
        initialRecipe: recipe,
        ingredients: widget.ingredients,
        onRecipeSaved: onRecipeSaved,
      ))
    );

  }

  void deleteRecipeRequest(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              deleteRecipe();
            },
            child: const Text('OK'),
          ),
        ],
      )
    );
  }

  void deleteRecipe(){
    widget.onRecipeDeleted(recipe.id);
    Navigator.pop(context);
  }

  void onRecipeSaved(Recipe newRecipe){
    widget.onRecipeSaved(newRecipe);
    setState(() => recipe = newRecipe);
  }
}
