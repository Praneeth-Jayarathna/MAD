class Generator {
  final int? id;
  final String name;
  final String imagePath;
  final String code;
  final String capacity;
  final String usage;
  final double remainingFuel;
  final int runningHours;

  const Generator({
    this.id,
    required this.name,
    required this.imagePath,
    this.code = '',
    this.capacity = '',
    this.usage = '',
    this.remainingFuel = 0,
    this.runningHours = 0,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'imagePath': imagePath,
        'code': code,
        'capacity': capacity,
        'usage': usage,
        'remainingFuel': remainingFuel,
        'runningHours': runningHours,
      };

  factory Generator.fromMap(Map<String, dynamic> map) => Generator(
        id: map['id'] as int?,
        name: map['name'] as String,
        imagePath: map['imagePath'] as String,
        code: map['code'] as String? ?? '',
        capacity: map['capacity'] as String? ?? '',
        usage: map['usage'] as String? ?? '',
        remainingFuel: (map['remainingFuel'] as num?)?.toDouble() ?? 0,
        runningHours: (map['runningHours'] as int?) ?? 0,
      );

  Generator copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? code,
    String? capacity,
    String? usage,
    double? remainingFuel,
    int? runningHours,
  }) =>
      Generator(
        id: id ?? this.id,
        name: name ?? this.name,
        imagePath: imagePath ?? this.imagePath,
        code: code ?? this.code,
        capacity: capacity ?? this.capacity,
        usage: usage ?? this.usage,
        remainingFuel: remainingFuel ?? this.remainingFuel,
        runningHours: runningHours ?? this.runningHours,
      );
}
