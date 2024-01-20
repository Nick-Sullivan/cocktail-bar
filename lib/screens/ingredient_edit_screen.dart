import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_app/model/ingredient.dart';


class IngredientEditScreen extends StatefulWidget {
  final Function(String) onIngredientDeleted;
  final Function(Ingredient) onIngredientSaved;
  final Ingredient initialIngredient;
  
  const IngredientEditScreen({
    super.key,
    required this.onIngredientDeleted,
    required this.onIngredientSaved,
    required this.initialIngredient,
  });

  @override
  State<IngredientEditScreen> createState() => _IngredientEditScreenState();
}

class _IngredientEditScreenState extends State<IngredientEditScreen> {
  late Ingredient ingredient;

  @override
  void initState() {
    ingredient = Ingredient.from(widget.initialIngredient);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          onPressed: ingredient.isValid() ? finishEditingIngredient : null,
          label: const Text('DONE'),
          style: ElevatedButton.styleFrom(
            primary: ingredient.color,
          ),
        ),
        backgroundColor: ingredient.color,
        actions: [
          IconButton(
            onPressed: () => deleteIngredientRequest(context),
            icon: const Icon(Icons.delete)
          )
        ],
      ),
      body: PageView(
        children: [
          IngredientEditWidget(
            onIngredientSaved: widget.onIngredientSaved,
            onIngredientUpdated: onIngredientUpdated,
            startingIngredient: ingredient,
          )
        ]
      )
    );
  }

  void onIngredientUpdated(Ingredient updatedIngredient){
    setState(() => ingredient = updatedIngredient);
  }

  void finishEditingIngredient(){
    widget.onIngredientSaved(ingredient);
    Navigator.pop(context);
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
    widget.onIngredientDeleted(ingredient.id);
    Navigator.pop(context);
  }

}


class IngredientEditWidget extends StatefulWidget {
  final Function(Ingredient) onIngredientSaved;
  final Function(Ingredient) onIngredientUpdated;
  final Ingredient startingIngredient;

  const IngredientEditWidget({
    super.key,
    required this.onIngredientSaved,
    required this.onIngredientUpdated,
    required this.startingIngredient
  });

  @override
  State<IngredientEditWidget> createState() => _IngredientEditWidgetState();
}

class _IngredientEditWidgetState extends State<IngredientEditWidget> {
  late Ingredient ingredient;

  @override
  void initState() {
    ingredient = Ingredient.from(widget.startingIngredient);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(child: buildNameTextField()),
              Expanded(child: buildColorPicker()),
            ],
          ),
          const SizedBox(height: 10),
          Center(child: buildStockedSection()),
          const SizedBox(height: 10),
          Center(child: buildAlcoholicSection()),
        ],
      )
    );
  }

  Widget buildColorPicker(){
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(ingredient.color),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: BlockPicker(
              onColorChanged: (color) {
                ingredient.color = color;
                widget.onIngredientUpdated(ingredient);
              },
              pickerColor: ingredient.color,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                },
                child: const Text('OK'),
              ),
            ],
          )
        );
      },
      child: const Text('Colour')
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      autofocus: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        hintText: 'Name',
      ),
      initialValue: ingredient.name,
      onChanged: (value) {
        setState(() => ingredient.name = value);
        widget.onIngredientUpdated(ingredient);
      },
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) => Ingredient.isValidName(value) ? null : 'Please enter a valid name.',
    );
  }

  Widget buildStockedSection() {
    return LayoutBuilder(
      builder: (context, constraints) => ToggleButtons(
        constraints: BoxConstraints.expand(width: constraints.maxWidth*0.4),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: ingredient.color,
        isSelected: [ingredient.isStocked, !ingredient.isStocked],
        fillColor: ingredient.color,
        onPressed: (int index) {
          setState(() {
            ingredient.isStocked = index == 0;
          });
          widget.onIngredientUpdated(ingredient);
        },
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
        color: ingredient.color,
        isSelected: [ingredient.isAlcoholic, !ingredient.isAlcoholic],
        fillColor: ingredient.color,
        onPressed: (int index) {
          setState(() {
            ingredient.isAlcoholic = index == 0;
          });
          widget.onIngredientUpdated(ingredient);
        },
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
