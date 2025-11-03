import 'dart:convert';
import '../variables.dart';
import 'package:http/http.dart' as http;
import '../models/coffee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<List<Coffee>> getCoffees({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coffees'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Coffee.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('Failed to load coffees: ${response.statusCode}');
    }
  }

  static Future<void> createCoffee(Coffee coffee) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/coffees'),
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(coffee.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create coffee');
    }
  }

  static Future<void> updateCoffee(int id, Coffee coffee) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/coffees/$id'),
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(coffee.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update coffee');
    }
  }

  static Future<void> deleteCoffee(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/coffees/$id'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete coffee');
    }
  }
}
