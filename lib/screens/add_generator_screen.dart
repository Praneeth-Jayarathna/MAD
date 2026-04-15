import 'package:flutter/material.dart';

class AddGeneratorScreen extends StatefulWidget {
  const AddGeneratorScreen({super.key});

  @override
  State<AddGeneratorScreen> createState() => _AddGeneratorScreenState();
}

class _AddGeneratorScreenState extends State<AddGeneratorScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _usageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _capacityController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  void _onAdd() {
    Navigator.pop(context, {
      'name': _nameController.text,
      'code': _codeController.text,
      'capacity': _capacityController.text,
      'usage': _usageController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Fuel Tracker',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image picker placeholder
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE8F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFF90B8E0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const _FieldLabel('Name'),
                    const SizedBox(height: 6),
                    _InputField(controller: _nameController),
                    const SizedBox(height: 16),

                    const _FieldLabel('Code'),
                    const SizedBox(height: 6),
                    _InputField(controller: _codeController),
                    const SizedBox(height: 16),

                    const _FieldLabel('Fuel Capacity (Litres)'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Fuel Usage (Litres Per Hour)'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _usageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2979FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
        ),
      ),
    );
  }
}
