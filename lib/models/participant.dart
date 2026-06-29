class Participant {
  final String id;
  final String eventId;
  final String nickname;
  final String? deviceToken;
  final DateTime joinedAt;

  const Participant({
    required this.id,
    required this.eventId,
    required this.nickname,
    this.deviceToken,
    required this.joinedAt,
  });

  String get initials {
    final parts = nickname.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return nickname.substring(0, nickname.length.clamp(0, 2)).toUpperCase();
  }
}
