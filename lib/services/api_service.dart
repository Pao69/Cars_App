import 'dart:convert';
import '../variables.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart'; // Import HttpHelper

class ApiService {
  static Future<String> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<List<Car>> getCars() async {
    String token = await _getToken();
    final response = await HttpHelper.get('/cars', token: token);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List) {
        return responseData
            .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load cars: ${response.statusCode}');
    }
  }

  static Future<void> createCar(Car car) async {
    String token = await _getToken();
    final response = await HttpHelper.post('/cars', car.toJson(), token: token);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create car');
    }
  }

  static Future<void> updateCar(int id, Car car) async {
    String token = await _getToken();
    final response = await HttpHelper.put(
      '/cars/$id',
      car.toJson(),
      token: token,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to update car: ${response.statusCode}');
    }
  }

  static Future<void> deleteCar(int id) async {
    String token = await _getToken();
    final response = await HttpHelper.delete('/cars/$id', token: token);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete car');
    }
  }
}
