import 'dart:io';

import 'package:flutter/material.dart';
import '../models/generator.dart';
import '../services/database_service.dart';
import 'generator_detail_screen.dart';
import 'add_generator_screen.dart';
import '../widgets/app_title.dart';

class GeneratorsScreen extends StatefulWidget {
  const GeneratorsScreen({super.key});

  @override
  State<GeneratorsScreen> createState() => _GeneratorsScreenState();
}

class _GeneratorsScreenState extends State<GeneratorsScreen> {
  final _db = DatabaseService();
  List<Generator> _generators = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGenerators();
  }

  Future<void> _loadGenerators() async {
    var list = await _db.getGenerators();
    if (list.isEmpty) {
      for (final name in [
        'Generator 01',
        'Generator 02',
        'Generator 03',
        'Generator 04',
      ]) {
        await _db.insertGenerator(
          Generator(name: name, imagePath: 'assets/images/gen1.jpeg'),
        );
      }
      list = await _db.getGenerators();
    }
    setState(() {
      _generators = list;
      _loading = false;
    });
  }

  void _deleteGenerator(int index) async {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Generator',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to delete the generator?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2979FF),
                        side: const BorderSide(color: Color(0xFF2979FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final g = _generators.removeAt(index);
                        if (g.id != null) await _db.deleteGenerator(g.id!);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addGenerator() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddGeneratorScreen()),
    );
    if (result != null) {
      final n = _generators.length + 1;
      final capacity = double.tryParse(result['capacity'] as String? ?? '') ?? 0;
      final g = Generator(
        name: (result['name'] as String?)?.isNotEmpty == true
            ? result['name'] as String
            : 'Generator ${n.toString().padLeft(2, '0')}',
        code: result['code'] as String? ?? '',
        capacity: result['capacity'] as String? ?? '',
        usage: result['usage'] as String? ?? '',
        imagePath: result['imagePath'] as String? ?? 'assets/images/gen1.jpeg',
        remainingFuel: (result['remainingFuel'] as num?)?.toDouble() ?? capacity,
      );
      final id = await _db.insertGenerator(g);
      setState(() => _generators.add(g.copyWith(id: id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AppTitle(),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _generators.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        return GeneratorCard(
                          generator: _generators[index],
                          onDelete: () => _deleteGenerator(index),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GeneratorDetailScreen(
                                  generator: _generators[index],
                                ),
                              ),
                            );
                            _loadGenerators();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _addGenerator,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 28,
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
    );
  }
}

class GeneratorCard extends StatelessWidget {
  final Generator generator;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const GeneratorCard({
    super.key,
    required this.generator,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    generator.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return buildGeneratorImage(
      generator.imagePath,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

Widget buildGeneratorImage(String path, {double? width, double? height, BoxFit? fit}) {
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => imagePlaceholder(width, height),
    );
  }
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => imagePlaceholder(width, height),
  );
}

Widget imagePlaceholder(double? width, double? height) {
  return Container(
    width: width,
    height: height ?? 180,
    color: const Color(0xFFE0E0E0),
    child: const Center(
      child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    ),
  );
}
