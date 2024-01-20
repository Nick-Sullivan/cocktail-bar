

class InstructionIngredient {
  String ingredientId;
  int startIndex;
  int endIndex;

  InstructionIngredient(this.ingredientId, this.startIndex, this.endIndex);

  factory InstructionIngredient.fromJson(Map<String, dynamic> map){
    return InstructionIngredient(
      map['ingredientId'],
      map['startIndex'],
      map['endIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'startIndex': startIndex,
      'endIndex': endIndex,
    };
  }

  bool overlaps(InstructionIngredient other){
    return (startIndex <= other.endIndex) && (endIndex >= other.startIndex);
  }

}
