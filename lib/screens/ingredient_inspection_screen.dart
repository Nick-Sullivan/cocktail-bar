import 'package:flutter/material.dart';
import 'package:my_app/model/ingredient.dart';
import 'package:my_app/screens/ingredient_edit_screen.dart';


class IngredientInspectionScreen extends StatefulWidget {
  final Ingredient ingredient;
  final Function(Ingredient) onSaveIngredient;
  final Function(String) onDeleteIngredient;
  
  const IngredientInspectionScreen({
    super.key,
    required this.ingredient,
    required this.onSaveIngredient,
    required this.onDeleteIngredient,
  });

  @override
  State<IngredientInspectionScreen> createState() => _IngredientInspectionScreenState();
}

class _IngredientInspectionScreenState extends State<IngredientInspectionScreen> {
  late Ingredient ingredient;

  @override
  void initState() {
    ingredient = Ingredient.from(widget.ingredient);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        children: [
          InspectIngredientWidget(
            ingredient: ingredient,
          )
        ],
      )
    );
  }

  AppBar buildAppBar(BuildContext context){
    return AppBar(
      title: Text(ingredient.name),
      backgroundColor: ingredient.color,
      actions: [
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
              editIngredient(context);
            }
            if (value == 1){
              deleteIngredientRequest(context);
            }
          }),
        )
      ]
    );
  }

  void editIngredient(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IngredientEditScreen(
        initialIngredient: ingredient,
        onIngredientSaved: onSaveIngredient,
        onIngredientDeleted: (_) {},
      ))
    );
  }

  void deleteIngredientRequest(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('All recipes that use this ingredient will be deleted.\r\nAre you sure you want to delete this ingredient?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              deleteIngredient();
            },
            child: const Text('OK'),
          ),
        ],
      )
    );
  }

  void deleteIngredient(){
    widget.onDeleteIngredient(ingredient.id);
    Navigator.pop(context);
  }

  void onSaveIngredient(Ingredient newIngredient){
    widget.onSaveIngredient(newIngredient);
    setState(() => ingredient = newIngredient);
  }
}


class InspectIngredientWidget extends StatefulWidget {
  final Ingredient ingredient;

  const InspectIngredientWidget({super.key, required this.ingredient});

  @override
  State<InspectIngredientWidget> createState() => _InspectIngredientWidgetState();
}

class _InspectIngredientWidgetState extends State<InspectIngredientWidget> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Center(child: buildStockedSection()),
          const SizedBox(height: 10),
          Center(child: buildAlcoholicSection()),
        ],
      )
    );
  }

  Widget buildStockedSection() {
    return LayoutBuilder(
      builder: (context, constraints) => ToggleButtons(
        constraints: BoxConstraints.expand(width: constraints.maxWidth*0.4),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: widget.ingredient.color,
        isSelected: [widget.ingredient.isStocked, !widget.ingredient.isStocked],
        fillColor: widget.ingredient.color,
        onPressed: (_) {},
        selectedColor: Colors.white,
        children: const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Stocked', style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Not stocked', style: TextStyle(fontSize: 18)),
          ),
        ],
      )
    );
  }

  Widget buildAlcoholicSection() {
    return LayoutBuilder(
      builder: (context, constraints) => ToggleButtons(
        constraints: BoxConstraints.expand(width: constraints.maxWidth*0.4),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: widget.ingredient.color,
        isSelected: [widget.ingredient.isAlcoholic, !widget.ingredient.isAlcoholic],
        fillColor: widget.ingredient.color,
        onPressed: (_) {},
        selectedColor: Colors.white,
        children: const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Alcoholic', style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Not alcoholic', style: TextStyle(fontSize: 18)),
          ),
        ],
      )
    );
  }

}
