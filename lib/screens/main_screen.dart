import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/ingredient_factory.dart';
import 'package:my_app/model/recipe_factory.dart';
import 'package:my_app/model/recipe_stage.dart';
import 'package:my_app/model/settings.dart';
import 'package:my_app/screens/ingredient_edit_screen.dart';
import 'package:my_app/screens/recipe_inspection_screen.dart';
import 'package:my_app/screens/recipe_edit_screen.dart';
import 'package:my_app/screens/settings_screen.dart';
import 'package:my_app/shared/rotating_menu_item.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
final getIt = GetIt.instance;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController pageController = PageController();
  final TextEditingController txtName = TextEditingController();
  final IngredientFactory ingredientFactory = getIt<IngredientFactory>();
  final RecipeFactory recipeFactory = getIt<RecipeFactory>();
  final Settings settingsPreferences = getIt<Settings>();

  List<Ingredient> ingredients = [];
  List<Recipe> recipes = [];
  bool? stockedFilter;
  bool? alcoholicFilter;
  int pageIndex = 0;

  /// Called once when this is first created
  @override
  void initState() {
    ingredientFactory.init().then((_) => loadIngredients());
    recipeFactory.init().then((_) => loadRecipes());
    super.initState();
  }

  /// Loads the state from the database, and tells the system the state has changed
  void loadIngredients() {
    ingredients = ingredientFactory.getList();
    setState(() {});
  }
  
  void loadRecipes() {
    recipes = recipeFactory.getList();
    setState(() {});
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          buildPage(buildIngredientTiles()),
          buildPage(buildRecipeTiles()),
        ],
      ),
      floatingActionButton: buildAddNewButton(),
    );
  }

  AppBar buildAppBar(){
    return AppBar(
      title: const Text('Cocktails'),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.filter_list),
          itemBuilder: (_) {
            return [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: RotatingMenuItem(
                  initialIndex: filterToIndex(stockedFilter),
                  onIndexUpdated: (index) => setState(() => stockedFilter = indexToFilter(index)),
                  textOptions: const ["Stocked & Unstocked", "Stocked", "Unstocked"],
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: RotatingMenuItem(
                  initialIndex: filterToIndex(alcoholicFilter),
                  onIndexUpdated: (index) => setState(() => alcoholicFilter = indexToFilter(index)),
                  textOptions: const ["Alcoholic & Nonalcoholic", "Alcoholic", "Nonalcoholic"],
                ),
              ),
            ];
          },
        ),
        PopupMenuButton(
          itemBuilder: (_) {
            return [
              const PopupMenuItem(
                value: 0,
                child: Text("Settings"),
              ),
            ];
          },
          onSelected: ((value) {
            if (value == 0){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen())
              ).then((value) {
                loadIngredients();
                loadRecipes();
              });
            }
          }),
        ),
      ],
    );
  }

  List<Widget> buildIngredientTiles(){
    List<Widget> tiles = [];
    for (final ingredient in ingredients){
      if (!isIngredientFiltered(ingredient)){
        continue;
      }
      tiles.add(
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ingredient.name),
              Switch(
                activeColor: Colors.green,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red,
                value: ingredient.isStocked,
                onChanged: (value) {
                  setState(() => ingredient.isStocked = value);
                  onSaveIngredient(ingredient);
                }
              ),
            ]
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IngredientEditScreen(
                initialIngredient: ingredient,
                onIngredientSaved: onSaveIngredient,
                onIngredientDeleted: onDeleteIngredient,
              ))
            );
          },
        ),
      );
    }
    return tiles;
  }
  
  List<Widget> buildRecipeTiles(){
    List<Widget> tiles = [];
    for (final recipe in recipes){
      if (!isRecipeFiltered(recipe)){
        continue;
      }
      tiles.add(
        ListTile(
          title: Text(recipe.name),
          trailing: buildStarRating(recipe),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeInspectionScreen(
                initialRecipe: recipe,
                ingredients: ingredients,
                onRecipeSaved: onSaveRecipe,
                onRecipeDeleted: onDeleteRecipe,
              ))
            );
          },
        ),
      );
    }
    return tiles;
  }

  Widget buildStarRating(Recipe recipe) {
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
  
  Widget buildPage(List<Widget> tiles){
    return Column(
      children: [
        buildPageToggle(),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              return tiles[index];
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 0,
                thickness: 1,
              );
            },
            itemCount: tiles.length,
          ),
        )
      ]
    );
  }

  Widget buildPageToggle(){
    return ToggleButtons(
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width / 2 - 2,
      ),
      isSelected: [pageIndex == 0, pageIndex == 1],
      onPressed: (int index) {
        setState(() => pageIndex = index);
        pageController.jumpToPage(index);
      },
      children: const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Ingredients', style: TextStyle(fontSize: 18)),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Recipes', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  FloatingActionButton buildAddNewButton(){
    if (pageIndex == 0){
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IngredientEditScreen(
              initialIngredient: Ingredient(createUniqueKey()),
              onIngredientSaved: onSaveIngredient,
              onIngredientDeleted: onDeleteIngredient,
            ))
          );
        },
        child: const Icon(Icons.add),
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeEditScreen(
              initialRecipe: Recipe(createUniqueKey()),
              ingredients: ingredients,
              onRecipeSaved: onSaveRecipe,
            ))
          );
        },
        child: const Icon(Icons.add),
      );
    }
  }

  bool isIngredientFiltered(Ingredient ingredient){
    if (ingredient.isAlcoholic && alcoholicFilter == false){
      return false;
    }
    if (!ingredient.isAlcoholic && alcoholicFilter == true){
      return false;
    }
    if (ingredient.isStocked && stockedFilter == false){
      return false;
    }
    if (!ingredient.isStocked && stockedFilter == true){
      return false;
    }

    return true;
  }

  bool isRecipeFiltered(Recipe recipe){
    var isRecipeAlcoholic = false;
    var isRecipeStocked = true;

    for (var stage in recipe.stages){
      if (!settingsPreferences.isDecorationIncluded && stage.stage == Stage.decorate) {
        continue;
      }
      for (var instructionIngredient in stage.instructionIngredients){
        var ingredient = ingredients.firstWhere((i) => i.id == instructionIngredient.ingredientId);
        if (ingredient.isAlcoholic) {
          isRecipeAlcoholic = true;
        }
        if (!ingredient.isStocked){
          isRecipeStocked = false;
        }
      }
    }
    
    if (isRecipeAlcoholic && alcoholicFilter == false){
      return false;
    }
    if (!isRecipeAlcoholic && alcoholicFilter == true){
      return false;
    }
    if (isRecipeStocked && stockedFilter == false){
      return false;
    }
    if (!isRecipeStocked && stockedFilter == true){
      return false;
    }
    return true;
  }

  void onSaveIngredient(Ingredient ingredient) {
    debugPrint('Requesting creation of ingredient name ${ingredient.name}');
    ingredientFactory.save(ingredient)
      .then((_) => loadIngredients());
  }

  void onDeleteIngredient(String id){
    debugPrint('Requesting deletion of ingredient id $id');
    ingredientFactory.delete(id)
      .then((value) => loadIngredients());
  }

  void onSaveRecipe(Recipe recipe){
    debugPrint('Requesting saving of my recipe name ${recipe.name}');
    recipeFactory.save(recipe)
      .then((_) => loadRecipes());
  }

  void onDeleteRecipe(String id) {
    debugPrint('Requesting deletion of my recipe id $id');
    recipeFactory.delete(id)
      .then((_) => loadRecipes());
  }

}
