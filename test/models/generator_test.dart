import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tracker/models/generator.dart';

void main() {
  group('Generator model', () {
    test('creates with default values', () {
      const g = Generator(name: 'Test', imagePath: 'assets/img.jpg');
      expect(g.id, isNull);
      expect(g.name, 'Test');
      expect(g.imagePath, 'assets/img.jpg');
      expect(g.code, '');
      expect(g.capacity, '');
      expect(g.usage, '');
      expect(g.remainingFuel, 0.0);
      expect(g.runningHours, 0);
    });

    test('creates with all values', () {
      const g = Generator(
        id: 1,
        name: 'Gen A',
        imagePath: 'assets/gen.jpg',
        code: 'G001',
        capacity: '500',
        usage: '5',
        remainingFuel: 300,
        runningHours: 120,
      );
      expect(g.id, 1);
      expect(g.name, 'Gen A');
      expect(g.code, 'G001');
      expect(g.capacity, '500');
      expect(g.usage, '5');
      expect(g.remainingFuel, 300.0);
      expect(g.runningHours, 120);
    });

    test('toMap returns correct map', () {
      const g = Generator(
        id: 1,
        name: 'Gen B',
        imagePath: 'assets/gen.jpg',
        code: 'G002',
        capacity: '1000',
        usage: '8',
        remainingFuel: 500,
        runningHours: 200,
      );
      final map = g.toMap();
      expect(map['name'], 'Gen B');
      expect(map['imagePath'], 'assets/gen.jpg');
      expect(map['code'], 'G002');
      expect(map['capacity'], '1000');
      expect(map['usage'], '8');
      expect(map['remainingFuel'], 500.0);
      expect(map['runningHours'], 200);
      expect(map.containsKey('id'), false);
    });

    test('fromMap creates correct instance', () {
      final map = <String, dynamic>{
        'id': 2,
        'name': 'Gen C',
        'imagePath': 'assets/gen3.jpg',
        'code': 'G003',
        'capacity': '250',
        'usage': '3.5',
        'remainingFuel': 100.0,
        'runningHours': 50,
      };
      final g = Generator.fromMap(map);
      expect(g.id, 2);
      expect(g.name, 'Gen C');
      expect(g.imagePath, 'assets/gen3.jpg');
      expect(g.code, 'G003');
      expect(g.capacity, '250');
      expect(g.usage, '3.5');
      expect(g.remainingFuel, 100.0);
      expect(g.runningHours, 50);
    });

    test('fromMap handles missing optional fields', () {
      final map = <String, dynamic>{
        'name': 'Gen D',
        'imagePath': 'assets/gen4.jpg',
      };
      final g = Generator.fromMap(map);
      expect(g.name, 'Gen D');
      expect(g.code, '');
      expect(g.capacity, '');
      expect(g.usage, '');
      expect(g.remainingFuel, 0.0);
      expect(g.runningHours, 0);
    });

    test('toMap / fromMap roundtrip preserves data', () {
      const original = Generator(
        id: 5,
        name: 'Roundtrip',
        imagePath: 'assets/rt.jpg',
        code: 'RT01',
        capacity: '750',
        usage: '6',
        remainingFuel: 400,
        runningHours: 90,
      );
      final map = original.toMap();
      final restored = Generator.fromMap({...map, 'id': original.id});
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.imagePath, original.imagePath);
      expect(restored.code, original.code);
      expect(restored.capacity, original.capacity);
      expect(restored.usage, original.usage);
      expect(restored.remainingFuel, original.remainingFuel);
      expect(restored.runningHours, original.runningHours);
    });

    test('copyWith overrides specified fields', () {
      const g = Generator(
        id: 1,
        name: 'Original',
        imagePath: 'assets/a.jpg',
        code: 'C001',
        capacity: '500',
        usage: '5',
        remainingFuel: 300,
        runningHours: 100,
      );
      final copy = g.copyWith(
        name: 'Modified',
        remainingFuel: 200,
        runningHours: 150,
      );
      expect(copy.name, 'Modified');
      expect(copy.remainingFuel, 200.0);
      expect(copy.runningHours, 150);
      expect(copy.code, 'C001');
      expect(copy.capacity, '500');
      expect(copy.imagePath, 'assets/a.jpg');
    });

    test('copyWith keeps original when no args', () {
      const g = Generator(
        id: 1,
        name: 'Same',
        imagePath: 'assets/s.jpg',
      );
      final copy = g.copyWith();
      expect(copy.name, 'Same');
      expect(copy.imagePath, 'assets/s.jpg');
      expect(copy.runningHours, 0);
    });
  });
}
