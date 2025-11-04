import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';

class CarFormScreen extends StatefulWidget {
  final Car? car; // null = add, not null = edit
  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!.brand ?? '';
      _modelController.text = widget.car!.model ?? '';
      _colorController.text = widget.car!.color ?? '';
      _yearController.text = widget.car!.year?.toString() ?? '';
      _priceController.text = widget.car!.price?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.car == null ? 'Add Car' : 'Edit Car')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter brand' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter model' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter color' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter year' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveCar,
                      child: Text(widget.car == null ? 'Save' : 'Update'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final car = Car(
      id: widget.car?.id,
      brand: _brandController.text,
      model: _modelController.text,
      color: _colorController.text,
      year: int.tryParse(_yearController.text),
      price: double.tryParse(_priceController.text),
    );

    try {
      if (widget.car == null) {
        await ApiService.createCar(car);
      } else if (widget.car!.id != null) {
        await ApiService.updateCar(widget.car!.id!, car);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
