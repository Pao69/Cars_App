import 'dart:convert';
import '../variables.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<List<Car>> getCars({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars'),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List) {
        return responseData
            .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception('Invalid data format: response is not a list');
      }
    } else {
      throw Exception('Failed to load cars: ${response.statusCode}');
    }
  }

  static Future<void> createCar(Car car) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/cars'),
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(car.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create car');
    }
  }

  static Future<void> updateCar(int id, Car car) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/cars/$id'),
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(car.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to update car: ${response.statusCode}');
    }
  }

  static Future<void> deleteCar(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cars/$id'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete car');
    }
  }
}
