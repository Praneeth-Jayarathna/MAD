import 'package:flutter/material.dart';
import 'generators_screen.dart';
import 'fuel_log_detail_screen.dart';
import 'running_hours_screen.dart';
import '../widgets/app_title.dart';

class GeneratorDetailScreen extends StatefulWidget {
  final Generator generator;

  const GeneratorDetailScreen({super.key, required this.generator});

  @override
  State<GeneratorDetailScreen> createState() => _GeneratorDetailScreenState();
}

class _GeneratorDetailScreenState extends State<GeneratorDetailScreen> {
  int _runningHours = 12;
  String _fuelLogDate = '2026-04-02';
  String _fuelLogLitres = '50';
  String _fuelLogRate = '350';

  Future<void> _openRunningHours() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => RunningHoursScreen(
          generator: widget.generator,
          initialHours: _runningHours,
        ),
      ),
    );
    if (result != null) {
      setState(() => _runningHours = result);
    }
  }

  Future<void> _openFuelLog() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => FuelLogDetailScreen(
          generator: widget.generator,
          date: _fuelLogDate,
          litresAdded: _fuelLogLitres,
          rate: _fuelLogRate,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _fuelLogDate = result['date'] ?? _fuelLogDate;
        _fuelLogLitres = result['litresAdded'] ?? _fuelLogLitres;
        _fuelLogRate = result['rate'] ?? _fuelLogRate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const AppTitle(),

              // Hero image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    widget.generator.imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: const Color(0xFFE0E0E0),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Name + model
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.generator.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.generator.code.isNotEmpty
                                ? widget.generator.code
                                : 'N/A',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        widget.generator.capacity.isNotEmpty
                            ? '${widget.generator.capacity} Litres Tank Capacity'
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        widget.generator.usage.isNotEmpty
                            ? '${widget.generator.usage} Litres Per Hour Usage'
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _InfoCard(child: _BoldLabel('10 Litres Remaining')),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openRunningHours,
                      child: _InfoCard(
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        child: _BoldLabel('$_runningHours Running Hours Per Day'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _openFuelLog,
                      child: _InfoCard(
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fuelLogDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_fuelLogLitres Litres Added with Rs.$_fuelLogRate Per Litre',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Widget? trailing;

  const _InfoCard({required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _BoldLabel extends StatelessWidget {
  final String text;
  const _BoldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}
