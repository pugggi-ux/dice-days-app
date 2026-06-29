class Game {
  final String id;
  final String eventId;
  final String name;
  final String? bggId;
  final String? imageUrl;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final double? weight;
  final String? description;
  final GameStatus status;
  final PackStatus packStatus;
  final List<String> interestedParticipantIds;
  final List<String> explainerParticipantIds;
  final List<String> supplierParticipantIds;
  final List<String> needsExplanationParticipantIds;
  final List<String> hiddenByParticipantIds;
  final DateTime createdAt;

  const Game({
    required this.id,
    required this.eventId,
    required this.name,
    this.bggId,
    this.imageUrl,
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.weight,
    this.description,
    this.status = GameStatus.unplanned,
    this.packStatus = PackStatus.toPack,
    this.interestedParticipantIds = const [],
    this.explainerParticipantIds = const [],
    this.supplierParticipantIds = const [],
    this.needsExplanationParticipantIds = const [],
    this.hiddenByParticipantIds = const [],
    required this.createdAt,
  });

  double get sweetSpot {
    if (maxPlayers == null || maxPlayers == 0) return 0;
    return interestedParticipantIds.length / maxPlayers!;
  }

  bool get isHot => sweetSpot > 1.0;

  bool get hasBottleneck =>
      explainerParticipantIds.isEmpty || supplierParticipantIds.isEmpty;

  String? get bottleneckText {
    final missing = <String>[];
    if (explainerParticipantIds.isEmpty) missing.add('Kein Erklärer');
    if (supplierParticipantIds.isEmpty) missing.add('Kein Lieferant');
    return missing.isEmpty ? null : missing.join(' · ');
  }

  bool isInterestedBy(String participantId) =>
      interestedParticipantIds.contains(participantId);

  bool isExplainedBy(String participantId) =>
      explainerParticipantIds.contains(participantId);

  bool isSuppliedBy(String participantId) =>
      supplierParticipantIds.contains(participantId);

  bool needsExplanationBy(String participantId) =>
      needsExplanationParticipantIds.contains(participantId);

  bool isHiddenBy(String participantId) =>
      hiddenByParticipantIds.contains(participantId);

  Game copyWith({
    String? name,
    String? imageUrl,
    GameStatus? status,
    PackStatus? packStatus,
    List<String>? interestedParticipantIds,
    List<String>? explainerParticipantIds,
    List<String>? supplierParticipantIds,
    List<String>? needsExplanationParticipantIds,
    List<String>? hiddenByParticipantIds,
  }) {
    return Game(
      id: id,
      eventId: eventId,
      name: name ?? this.name,
      bggId: bggId,
      imageUrl: imageUrl ?? this.imageUrl,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      playingTimeMinutes: playingTimeMinutes,
      weight: weight,
      description: description,
      status: status ?? this.status,
      packStatus: packStatus ?? this.packStatus,
      interestedParticipantIds:
          interestedParticipantIds ?? this.interestedParticipantIds,
      explainerParticipantIds:
          explainerParticipantIds ?? this.explainerParticipantIds,
      supplierParticipantIds:
          supplierParticipantIds ?? this.supplierParticipantIds,
      needsExplanationParticipantIds:
          needsExplanationParticipantIds ?? this.needsExplanationParticipantIds,
      hiddenByParticipantIds:
          hiddenByParticipantIds ?? this.hiddenByParticipantIds,
      createdAt: createdAt,
    );
  }
}

enum GameStatus { unplanned, planned, played }

enum PackStatus { toPack, giveGet, done }
