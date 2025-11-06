import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_form_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  late Future<List<Car>> _carList;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await _getToken();
    _refreshCars();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  void _refreshCars() {
    setState(() {
      _carList = ApiService.getCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car List')),
      body: _token == null
          ? const Center(child: Text('Loading...'))
          : FutureBuilder<List<Car>>(
              future: _carList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading cars...'));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cars found'));
                }

                final cars = snapshot.data!;
                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return ListTile(
                      title: Text(
                        '${car.brand ?? 'No Brand'} ${car.model ?? 'No Model'}',
                      ),
                      subtitle: Text(
                        '${car.color ?? 'No Color'}, ${car.year ?? 'No Year'}, ${car.price ?? 'No Price'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              try {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarFormScreen(car: car),
                                  ),
                                );
                                if (updated == true) _refreshCars();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error updating car: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete "${car.brand} ${car.model}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await ApiService.deleteCar(car.id!);
                                  _refreshCars();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting car: $e'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final added = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CarFormScreen()),
            );
            if (added == true) _refreshCars();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error adding car: $e')));
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
