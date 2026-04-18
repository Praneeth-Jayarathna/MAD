import 'package:flutter/material.dart';
import 'generators_screen.dart';
import '../widgets/app_title.dart';

class RunningHoursScreen extends StatefulWidget {
  final Generator generator;
  final int initialHours;

  const RunningHoursScreen({
    super.key,
    required this.generator,
    this.initialHours = 12,
  });

  @override
  State<RunningHoursScreen> createState() => _RunningHoursScreenState();
}

class _RunningHoursScreenState extends State<RunningHoursScreen> {
  late int _hours;
  int _activeDigit = 1; // 0 = tens, 1 = units

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours.clamp(0, 99);
  }

  int get _tens => _hours ~/ 10;
  int get _units => _hours % 10;

  void _onDigitTap(int digitIndex) {
    setState(() => _activeDigit = digitIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppTitle(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Hero image
                    ClipRRect(
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
                    const SizedBox(height: 12),

                    // Generator name
                    Text(
                      widget.generator.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Digit boxes + label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _DigitBox(
                          digit: _tens,
                          isActive: _activeDigit == 0,
                          onTap: () => _onDigitTap(0),
                        ),
                        const SizedBox(width: 12),
                        _DigitBox(
                          digit: _units,
                          isActive: _activeDigit == 1,
                          onTap: () => _onDigitTap(1),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Hours',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Number pad
                    const SizedBox(height: 32),
                    _NumberPad(onKey: _onKey),

                    const Spacer(),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black54,
                            builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  28,
                                  24,
                                  20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Update Hour',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Are you sure you want to run the generator ${_hours.toString().padLeft(2, '0')} Hours a day?',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFF2979FF,
                                              ),
                                              side: const BorderSide(
                                                color: Color(0xFF2979FF),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context, _hours);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2979FF,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Confirm',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2979FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  void _onKey(String key) {
    setState(() {
      if (key == '<') {
        // backspace — clear active digit
        if (_activeDigit == 1) {
          _hours = (_tens * 10).clamp(0, 99);
          _activeDigit = 0;
        } else {
          _hours = _units.clamp(0, 99);
        }
      } else {
        final digit = int.parse(key);
        if (_activeDigit == 0) {
          final newHours = digit * 10 + _units;
          _hours = newHours.clamp(0, 99);
          _activeDigit = 1;
        } else {
          final newHours = _tens * 10 + digit;
          _hours = newHours.clamp(0, 99);
        }
      }
    });
  }
}

class _DigitBox extends StatelessWidget {
  final int digit;
  final bool isActive;
  final VoidCallback onTap;

  const _DigitBox({
    required this.digit,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF2979FF) : Colors.grey.shade300,
            width: isActive ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$digit',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF2979FF) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onKey;

  const _NumberPad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 72, height: 52);
            return GestureDetector(
              onTap: () => onKey(key),
              child: SizedBox(
                width: 72,
                height: 52,
                child: Center(
                  child: key == '<'
                      ? const Icon(
                          Icons.backspace_outlined,
                          size: 22,
                          color: Colors.black54,
                        )
                      : Text(
                          key,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
