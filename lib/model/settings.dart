

class Settings {
  bool isDecorationIncluded;

  Settings({
    this.isDecorationIncluded = false,
  });

  factory Settings.fromJson(Map<String, dynamic> map){
    return Settings(
      isDecorationIncluded: map['isDecorationIncluded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDecorationIncluded': isDecorationIncluded,
    };
  }
}
