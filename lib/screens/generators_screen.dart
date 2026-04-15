import 'package:flutter/material.dart';
import 'generator_detail_screen.dart';
import 'add_generator_screen.dart';

class Generator {
  final String name;
  final String imagePath;

  const Generator({required this.name, required this.imagePath});
}

class GeneratorsScreen extends StatefulWidget {
  const GeneratorsScreen({super.key});

  @override
  State<GeneratorsScreen> createState() => _GeneratorsScreenState();
}

class _GeneratorsScreenState extends State<GeneratorsScreen> {
  final List<Generator> _generators = [
    const Generator(name: 'Generator 01', imagePath: 'assets/images/gen1.jpeg'),
    const Generator(name: 'Generator 02', imagePath: 'assets/images/gen2.jpg'),
    const Generator(name: 'Generator 03', imagePath: 'assets/images/gen3.jpg'),
    const Generator(name: 'Generator 04', imagePath: 'assets/images/gen4.jpg'),
  ];

  void _deleteGenerator(int index) {
    setState(() => _generators.removeAt(index));
  }

  void _addGenerator() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const AddGeneratorScreen()),
    );
    if (result != null) {
      setState(() {
        final n = _generators.length + 1;
        _generators.add(Generator(
          name: result['name']?.isNotEmpty == true
              ? result['name']!
              : 'Generator ${n.toString().padLeft(2, '0')}',
          imagePath: 'assets/images/gen1.jpg',
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Fuel Tracker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      return GeneratorCard(
                        generator: _generators[index],
                        onDelete: () => _deleteGenerator(index),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GeneratorDetailScreen(
                              generator: _generators[index],
                            ),
                          ),
                        ),
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
                      child: const Icon(Icons.add, color: Colors.grey, size: 28),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
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
    return Image.asset(
      generator.imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE0E0E0),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
