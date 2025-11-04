class Car {
  int? id;
  String? brand;
  String? model;
  String? color;
  int? year;
  double? price;

  Car({this.id, this.brand, this.model, this.color, this.year, this.price});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      color: json['color']?.toString(),
      year: json['year'] != null ? int.tryParse(json['year'].toString()) : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'brand': brand ?? '',
      'model': model ?? '',
      'color': color ?? '',
      'year': year?.toString() ?? '',
      'price': price?.toString() ?? '',
    };
  }
}
