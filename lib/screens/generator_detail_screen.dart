import 'package:flutter/material.dart';
import '../models/generator.dart';
import '../models/fuel_log.dart';
import '../services/database_service.dart';
import 'generators_screen.dart';
import 'fuel_log_detail_screen.dart';
import 'record_run_screen.dart';
import '../widgets/app_title.dart';

class GeneratorDetailScreen extends StatefulWidget {
  final Generator generator;

  const GeneratorDetailScreen({super.key, required this.generator});

  @override
  State<GeneratorDetailScreen> createState() => _GeneratorDetailScreenState();
}

class _GeneratorDetailScreenState extends State<GeneratorDetailScreen> {
  final _db = DatabaseService();
  late Generator _generator;
  List<FuelLog> _fuelLogs = [];

  @override
  void initState() {
    super.initState();
    _generator = widget.generator;
    _loadGenerator();
  }

  Future<void> _loadGenerator() async {
    if (widget.generator.id == null) return;
    final g = await _db.getGenerator(widget.generator.id!);
    if (g != null && mounted) {
      setState(() => _generator = g);
      _loadFuelLogs();
    }
  }

  Future<void> _loadFuelLogs() async {
    if (_generator.id == null) return;
    final logs = await _db.getFuelLogs(_generator.id!);
    if (mounted) setState(() => _fuelLogs = logs);
  }

  Future<void> _recordRun() async {
    final result = await Navigator.push<Generator>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordRunScreen(generator: _generator),
      ),
    );
    if (result != null) {
      setState(() => _generator = result);
    }
  }

  Future<void> _openFuelLog() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => FuelLogDetailScreen(
          generator: _generator,
          date: DateTime.now().toIso8601String().split('T')[0],
          litresAdded: '',
          rate: '',
        ),
      ),
    );
    if (result != null && _generator.id != null) {
      final litres = double.tryParse(result['litresAdded'] ?? '') ?? 0;
      final rate = result['rate'] ?? '';
      final date = result['date'] ?? '';

      final newFuel = _generator.remainingFuel + litres;
      await _db.insertFuelLog(
        FuelLog(generatorId: _generator.id!, date: date, litresAdded: litres.toString(), rate: rate),
      );
      setState(() {
        _generator = _generator.copyWith(remainingFuel: newFuel);
      });
      await _db.updateGenerator(_generator);
      _loadFuelLogs();
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
              const AppTitle(),

              // Hero image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: buildGeneratorImage(
                    _generator.imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generator.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _generator.code.isNotEmpty
                                ? _generator.code
                                : 'N/A',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        _generator.capacity.isNotEmpty
                            ? '${_generator.capacity} Litres Tank Capacity'
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        _generator.usage.isNotEmpty
                            ? '${_generator.usage} Litres Per Hour Usage'
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        '${_generator.remainingFuel.toStringAsFixed(1)} Litres Remaining',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: _BoldLabel(
                        '${_generator.runningHours} Total Running Hours',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _recordRun,
                      child: _InfoCard(
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Record Run Session',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to log running hours',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
                            const Text(
                              'Add Fuel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to record fuel addition',
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

                    // Fuel log history header
                    if (_fuelLogs.isNotEmpty) ...[
                      const Text(
                        'Fuel History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._fuelLogs.map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _InfoCard(
                          child: Row(
                            children: [
                              Text(
                                log.date,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '+${log.litresAdded} L',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rs. ${log.rate}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
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
