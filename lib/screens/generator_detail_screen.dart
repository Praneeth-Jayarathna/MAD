import 'package:flutter/material.dart';
import '../models/generator.dart';
import '../models/fuel_log.dart';
import '../models/running_log.dart';
import '../services/database_service.dart';
import 'generators_screen.dart';
import 'fuel_log_detail_screen.dart';
import 'record_run_screen.dart';
import 'add_generator_screen.dart';

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
  List<RunningLog> _runningLogs = [];

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
      await Future.wait([_loadFuelLogs(), _loadRunningLogs()]);
    }
  }

  Future<void> _loadFuelLogs() async {
    if (_generator.id == null) return;
    final logs = await _db.getFuelLogs(_generator.id!);
    if (mounted) setState(() => _fuelLogs = logs);
  }

  Future<void> _loadRunningLogs() async {
    if (_generator.id == null) return;
    final logs = await _db.getRunningLogs(_generator.id!);
    if (mounted) setState(() => _runningLogs = logs);
  }

  Future<void> _editGenerator() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGeneratorScreen(generator: _generator),
      ),
    );
    if (result != null && _generator.id != null) {
      final g = Generator(
        id: _generator.id,
        name: result['name'] as String,
        code: result['code'] as String,
        capacity: result['capacity'] as String,
        usage: result['usage'] as String,
        imagePath: result['imagePath'] as String,
        remainingFuel: _generator.remainingFuel,
        runningHours: _generator.runningHours,
      );
      await _db.updateGenerator(g);
      setState(() => _generator = g);
    }
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
      _loadRunningLogs();
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

  double get _fuelPercent {
    final cap = double.tryParse(_generator.capacity) ?? 0;
    if (cap <= 0) return 0;
    return (_generator.remainingFuel / cap).clamp(0.0, 1.0);
  }

  Color _fuelColor(double pct) {
    if (pct > 0.5) return Colors.green;
    if (pct > 0.25) return Colors.orange;
    return Colors.red;
  }

  String _fuelStatus(double pct) {
    if (pct > 0.5) return 'Good';
    if (pct > 0.25) return 'Low';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final pct = _fuelPercent;
    final fColor = _fuelColor(pct);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header with edit
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      'Generator Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                      onPressed: _editGenerator,
                    ),
                  ],
                ),
              ),

              // Hero image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: buildGeneratorImage(
                    _generator.imagePath,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name + code below image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generator.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _generator.code.isNotEmpty ? _generator.code : 'N/A',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: fColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _fuelStatus(pct),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: fColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Fuel level progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fuel Level',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${_generator.remainingFuel.toStringAsFixed(1)} / ${_generator.capacity} L',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFEEF1F7),
                          valueColor: AlwaysStoppedAnimation(fColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_gas_station,
                        label: 'Capacity',
                        value: '${_generator.capacity} L',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.speed,
                        label: 'Usage',
                        value: '${_generator.usage} L/h',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.access_time,
                        label: 'Run Time',
                        value: '${_generator.runningHours} h',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.play_circle_outline,
                        label: 'Record Run',
                        color: const Color(0xFF2979FF),
                        onTap: _recordRun,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Add Fuel',
                        color: Colors.green,
                        onTap: _openFuelLog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // History sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Running log history
                    if (_runningLogs.isNotEmpty) ...[
                      const Text(
                        'Run History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._runningLogs.take(5).map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _HistoryCard(
                          date: log.date,
                          main: '${log.hoursRun.toStringAsFixed(1)} hrs',
                          sub: '-${log.litresConsumed.toStringAsFixed(1)} L',
                          mainColor: const Color(0xFF2979FF),
                          subColor: Colors.orange,
                        ),
                      )),
                      if (_runningLogs.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                            child: Text(
                              '+${_runningLogs.length - 5} more entries',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // Fuel log history
                    if (_fuelLogs.isNotEmpty) ...[
                      const Text(
                        'Fuel History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._fuelLogs.take(5).map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _HistoryCard(
                          date: log.date,
                          main: '+${log.litresAdded} L',
                          sub: 'Rs. ${log.rate}',
                          mainColor: Colors.green,
                          subColor: Colors.black54,
                        ),
                      )),
                      if (_fuelLogs.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                            child: Text(
                              '+${_fuelLogs.length - 5} more entries',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                    ],

                    if (_runningLogs.isEmpty && _fuelLogs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No activity recorded yet.\nTap Record Run or Add Fuel to begin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String date;
  final String main;
  final String sub;
  final Color mainColor;
  final Color subColor;

  const _HistoryCard({
    required this.date,
    required this.main,
    required this.sub,
    required this.mainColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            date,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const Spacer(),
          Text(
            main,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: mainColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            sub,
            style: TextStyle(fontSize: 13, color: subColor),
          ),
        ],
      ),
    );
  }
}
