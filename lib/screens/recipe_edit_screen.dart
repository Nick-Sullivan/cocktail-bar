import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/ingredient.dart';
import 'package:my_app/model/instruction_ingredient.dart';
import 'package:my_app/model/recipe.dart';
import 'package:my_app/model/recipe_stage.dart';


class RecipeEditScreen extends StatefulWidget {
  final Recipe initialRecipe;
  final List<Ingredient> ingredients;
  final Function(Recipe) onRecipeSaved;
  
  const RecipeEditScreen({
    super.key,
    required this.initialRecipe,
    required this.ingredients,
    required this.onRecipeSaved,
  });

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();

  List<InstructionIngredient> detectIngredients(String instructions){
    var detected = <InstructionIngredient>[];
    for (var ingredient in ingredients){
      detected.addAll(detectIngredient(instructions.toLowerCase(), ingredient));
    }
    var seperated = removeOverlappingIngredients(detected);
    seperated.sort((a, b) => a.startIndex.compareTo(b.startIndex));
    return seperated;
  }

  static List<InstructionIngredient> detectIngredient(String str, Ingredient ingredient){
    var discoveredIngredients = <InstructionIngredient>[];
    var ingredientName = ingredient.name.toLowerCase();
    var lettersRegex = RegExp('^[a-zA-Z]+');

    var startIndex = str.indexOf(ingredientName);
    while (startIndex != -1){
      var endIndex = startIndex + ingredientName.length;

      var isWholeWord = (startIndex == 0 || !str[startIndex-1].contains(lettersRegex));

      if (isWholeWord){
        discoveredIngredients.add(InstructionIngredient(ingredient.id, startIndex, endIndex));
      }
      startIndex = str.indexOf(ingredientName, endIndex);
    }

    return discoveredIngredients;
  }

  static List<InstructionIngredient> removeOverlappingIngredients(List<InstructionIngredient> detected){
    // Remove overlapping detections, longer ingredients are chosen over shorter ingredients
    detected.sort((b, a) => (a.endIndex - a.startIndex).compareTo(b.endIndex - b.startIndex));
    var separated = <InstructionIngredient>[];
    for (var ingredient in detected){
      if (overlaps(ingredient, separated)){
        continue;
      }
      separated.add(ingredient);
    }
    return separated;
  }

  static bool overlaps(InstructionIngredient ingredient, List<InstructionIngredient> ingredientList){
    for (var i in ingredientList){
      if (ingredient.overlaps(i)){
        return true;
      }
    }
    return false;
  }

}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late Recipe recipe;
  final initialStages = [Stage.shake];

  @override
  void initState() {
    recipe = Recipe.from(widget.initialRecipe);
    if (recipe.stages.isEmpty){
      for (var stage in initialStages){
        recipe.stages.add(RecipeStage(
          createUniqueKey(),
          stage: stage
        ));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          onPressed: recipe.isValid() ? finishEditingRecipe : null,
          label: const Text('DONE'),
        ),
      ),
      body: PageView(
        children: [
          Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(child: buildNameTextField()),
                  Expanded(child: buildStarRating()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildCommentBox()),
                  Expanded(child: buildImageUpload()),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: ((oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = recipe.stages.removeAt(oldIndex);
                      recipe.stages.insert(newIndex, item);
                    });
                  }),
                  children: buildRecipeTiles(),
                ),
              ),
            ]
          ),
        ],
      ),
      floatingActionButton: buildNewStageButton(),
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      autofocus: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        hintText: 'Name',
      ),
      initialValue: recipe.name,
      onChanged: (value) {
        var validBefore = recipe.isValid();
        recipe.name = value;
        if (validBefore != recipe.isValid()){
          setState(() {});
        }
      },
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) => Recipe.isValidName(value) ? null : 'Please enter a valid name.',
    );
  }

  Widget buildStarRating() {
    return Center(child: RatingBar(
      initialRating: recipe.rating,
      allowHalfRating: true,
      itemCount: 5,
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: Colors.purple),
        half: const Icon(Icons.star_half, color: Colors.purple),
        empty: const Icon(Icons.star_outline, color: Colors.purple),
      ),
      onRatingUpdate: ((value) {
        recipe.rating = value;
      }),
    ));
  }

  Widget buildCommentBox(){
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: 'Review',
      ),
      initialValue: recipe.comment,
      maxLines: null,
      onChanged: (value) {
        recipe.comment = value;
      },
    );
  }

  Widget buildImageUpload(){
    return ListTile(
      title: const Icon(Icons.image),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Images are not yet supported.'),
        ));
      },
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
      key: UniqueKey(),
      title: Column(
        children: [
          buildDropdown(recipeStage),
          buildInstruction(recipeStage),
        ],
      )
    );
  }

  Widget buildDropdown(RecipeStage recipeStage){
    return DropdownButton<Stage>(
      isExpanded: true,
      items: Stage.values.map<DropdownMenuItem<Stage>>((Stage stage) {
        return DropdownMenuItem<Stage>(
          value: stage,
          child: Row(
            children: [
              Image(image: stageImages[stage]!),
              Text(
                stage.name,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black
                )
              )
            ]
          ),
        );
      }).toList(),
      onChanged: (Stage? value) {
        if (value == Stage.delete){
          deleteStage(recipeStage);
        } else {
          setState(() => recipeStage.stage = value!);
        }
      },
      underline: const SizedBox(),
      value: recipeStage.stage,
    );
  }

  Widget buildInstruction(RecipeStage recipeStage){
    return TextFormField(
      autofocus: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Instruction',
      ),
      initialValue: recipeStage.instructions,
      maxLines: null,
      onChanged: (value) {
        recipeStage.instructions = value;
      },
      textAlign: TextAlign.left,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  FloatingActionButton buildNewStageButton(){
    return FloatingActionButton(
      onPressed: () {
        var recipeStage = RecipeStage(createUniqueKey(), instructionIngredients: <InstructionIngredient>[]);
        setState(() => recipe.stages.add(recipeStage));
      },
      child: const Icon(Icons.add),
    );
  }

  void deleteStage(RecipeStage stage){
    var ind = recipe.stages.indexWhere((s) => s.id == stage.id);
    if (ind == -1){
      throw Exception('Something went wrong');
    }
    setState(() => recipe.stages.removeAt(ind));
  }

  void finishEditingRecipe(){
    for (var recipeStage in recipe.stages){
      recipeStage.instructionIngredients = widget.detectIngredients(recipeStage.instructions);
    }
    widget.onRecipeSaved(recipe);
    Navigator.pop(context);
  }

}
