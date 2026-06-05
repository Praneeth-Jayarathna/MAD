class FuelLog {
  final int? id;
  final int generatorId;
  final String date;
  final String litresAdded;
  final String rate;

  const FuelLog({
    this.id,
    required this.generatorId,
    required this.date,
    required this.litresAdded,
    required this.rate,
  });

  Map<String, dynamic> toMap() => {
        'generatorId': generatorId,
        'date': date,
        'litresAdded': litresAdded,
        'rate': rate,
      };

  factory FuelLog.fromMap(Map<String, dynamic> map) => FuelLog(
        id: map['id'] as int?,
        generatorId: map['generatorId'] as int,
        date: map['date'] as String,
        litresAdded: map['litresAdded'] as String,
        rate: map['rate'] as String,
      );
}
