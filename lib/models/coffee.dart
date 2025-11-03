class Coffee {
  int? id;
  String? coffee_type; // replaced 'code' with 'coffee_type'
  String? description;

  Coffee({this.id, this.coffee_type, this.description});

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id'],
      coffee_type: json['coffee_type']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coffee_type': coffee_type ?? '',
      'description': description ?? '',
    };
  }
}
