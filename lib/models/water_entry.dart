class WaterEntry {
  final int amount; // in milliliters
  final DateTime timestamp;

  WaterEntry({
    required this.amount,
    required this.timestamp,
  });

  // Convert WaterEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create WaterEntry from JSON
  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
