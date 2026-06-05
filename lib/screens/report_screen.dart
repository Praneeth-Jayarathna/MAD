import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/generator.dart';
import '../widgets/app_title.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _db = DatabaseService();
  late DateTime _startDate;
  late DateTime _endDate;
  String _period = 'week';
  bool _loading = true;

  double _totalConsumed = 0;
  double _totalAdded = 0;
  double _totalCost = 0;
  double _totalHours = 0;
  Map<int, double> _consumedByGen = {};
  Map<int, double> _addedByGen = {};
  List<Generator> _generators = [];

  @override
  void initState() {
    super.initState();
    _setPeriod('week');
  }

  void _setPeriod(String period) {
    final now = DateTime.now();
    _period = period;
    switch (period) {
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
      case 'custom':
        return;
    }
    _loadData();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _db.totalFuelConsumed(_startDate, _endDate),
      _db.totalFuelAdded(_startDate, _endDate),
      _db.totalFuelCost(_startDate, _endDate),
      _db.totalRunningHours(_startDate, _endDate),
      _db.fuelConsumedByGenerator(_startDate, _endDate),
      _db.fuelAddedByGenerator(_startDate, _endDate),
      _db.getGenerators(),
    ]);

    if (mounted) {
      setState(() {
        _totalConsumed = results[0] as double;
        _totalAdded = results[1] as double;
        _totalCost = results[2] as double;
        _totalHours = results[3] as double;
        _consumedByGen = results[4] as Map<int, double>;
        _addedByGen = results[5] as Map<int, double>;
        _generators = results[6] as List<Generator>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AppTitle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _PeriodChip('Last Week', 'week', _period, onTap: () => _setPeriod('week')),
                const SizedBox(width: 8),
                _PeriodChip('Last Month', 'month', _period, onTap: () => _setPeriod('month')),
                const SizedBox(width: 8),
                _PeriodChip('Custom', 'custom', _period, onTap: () => _setPeriod('custom')),
              ],
            ),
          ),
          if (_period == 'custom') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'From',
                      date: _startDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
                  ),
                  Expanded(
                    child: _DateButton(
                      label: 'To',
                      date: _endDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(
                      title: 'Fuel Consumed',
                      value: '${_totalConsumed.toStringAsFixed(1)} L',
                      icon: Icons.local_gas_station,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: 'Fuel Added',
                      value: '${_totalAdded.toStringAsFixed(1)} L',
                      icon: Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: 'Total Cost',
                      value: 'Rs. ${_totalCost.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: 'Running Hours',
                      value: '${_totalHours.toStringAsFixed(1)} hrs',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 24),

                    if (_generators.isNotEmpty) ...[
                      const Text(
                        'Per Generator Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._generators.map((g) => _GeneratorRow(
                        generator: g,
                        consumed: _consumedByGen[g.id] ?? 0,
                        added: _addedByGen[g.id] ?? 0,
                      )),
                    ],

                    const SizedBox(height: 24),

                    // Forecast section
                    if (_totalConsumed > 0) ...[
                      const Text(
                        'Fuel Forecast',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildForecast(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    final days = _endDate.difference(_startDate).inDays + 1;
    final dailyConsumption = days > 0 ? _totalConsumed / days : 0.0;

    double totalRemaining = 0;
    for (final g in _generators) {
      totalRemaining += g.remainingFuel;
    }

    final daysRemaining =
        dailyConsumption > 0 ? (totalRemaining / dailyConsumption) : 0;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Avg. Daily Consumption: ${dailyConsumption.toStringAsFixed(1)} L',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Total Remaining: ${totalRemaining.toStringAsFixed(1)} L',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_view_day, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Est. Days Remaining: ${daysRemaining.toStringAsFixed(0)} days',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: daysRemaining < 7 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _PeriodChip(this.label, this.value, this.selected, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2979FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ds =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(ds, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratorRow extends StatelessWidget {
  final Generator generator;
  final double consumed;
  final double added;

  const _GeneratorRow({
    required this.generator,
    required this.consumed,
    required this.added,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              generator.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Consumed: ${consumed.toStringAsFixed(1)} L',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Text(
                  'Added: ${added.toStringAsFixed(1)} L',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
            Text(
              'Remaining: ${generator.remainingFuel.toStringAsFixed(1)} L',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
