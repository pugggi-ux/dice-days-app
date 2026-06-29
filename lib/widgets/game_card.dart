import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/game.dart';
import 'sweet_spot_indicator.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final String currentUserId;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 8),
              SweetSpotIndicator(ratio: game.sweetSpot),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 60,
        height: 60,
        child: game.imageUrl != null
            ? Image.network(
                game.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderCover(),
              )
            : _placeholderCover(),
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.extension, color: AppColors.neutral),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (game.bottleneckText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              game.bottleneckText!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Text(
          game.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildMeta(),
        const SizedBox(height: 6),
        _buildBadges(),
      ],
    );
  }

  Widget _buildMeta() {
    final parts = <String>[];
    if (game.minPlayers != null && game.maxPlayers != null) {
      parts.add('${game.minPlayers}–${game.maxPlayers} Sp.');
    }
    if (game.playingTimeMinutes != null) {
      parts.add('${game.playingTimeMinutes} Min.');
    }
    if (game.weight != null) {
      parts.add('${game.weight!.toStringAsFixed(1)} ★');
    }
    return Text(
      parts.join(' · '),
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Widget _buildBadges() {
    final badges = <Widget>[];
    if (game.interestedParticipantIds.isNotEmpty) {
      final isSelfInterested = game.isInterestedBy(currentUserId);
      badges.add(_badge(
        '${game.interestedParticipantIds.length} Interessenten',
        isSelfInterested ? AppColors.success : AppColors.neutral,
      ));
    }
    for (final explainerId in game.explainerParticipantIds) {
      final isMe = explainerId == currentUserId;
      badges.add(_badge(
        isMe ? 'Du erklärst' : 'Erklärer',
        AppColors.explainer,
      ));
    }
    return Wrap(spacing: 6, runSpacing: 4, children: badges);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
