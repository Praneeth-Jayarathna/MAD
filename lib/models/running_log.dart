class RunningLog {
  final int? id;
  final int generatorId;
  final String date;
  final double hoursRun;
  final double litresConsumed;

  const RunningLog({
    this.id,
    required this.generatorId,
    required this.date,
    required this.hoursRun,
    required this.litresConsumed,
  });

  Map<String, dynamic> toMap() => {
        'generatorId': generatorId,
        'date': date,
        'hoursRun': hoursRun,
        'litresConsumed': litresConsumed,
      };

  factory RunningLog.fromMap(Map<String, dynamic> map) => RunningLog(
        id: map['id'] as int?,
        generatorId: map['generatorId'] as int,
        date: map['date'] as String,
        hoursRun: (map['hoursRun'] as num).toDouble(),
        litresConsumed: (map['litresConsumed'] as num).toDouble(),
      );
}
