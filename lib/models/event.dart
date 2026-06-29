class DiceDaysEvent {
  final String id;
  final String name;
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final DateTime createdAt;

  const DiceDaysEvent({
    required this.id,
    required this.name,
    required this.code,
    required this.startDate,
    required this.endDate,
    this.location,
    required this.createdAt,
  });
}
