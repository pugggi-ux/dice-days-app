import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/game.dart';
import '../services/mock_data.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

enum GameFilter { all, interested, bottleneck }

class _GamesListScreenState extends State<GamesListScreen> {
  GameFilter _filter = GameFilter.all;
  late List<Game> _games;

  @override
  void initState() {
    super.initState();
    _games = List.of(mockGames);
  }

  List<Game> get _filteredGames {
    switch (_filter) {
      case GameFilter.all:
        return _games;
      case GameFilter.interested:
        return _games.where((g) => g.isInterestedBy(currentUserId)).toList();
      case GameFilter.bottleneck:
        return _games.where((g) => g.hasBottleneck).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mockEvent.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tanGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              mockEvent.code,
              style: const TextStyle(
                color: AppColors.tanGold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return GameCard(
                  game: game,
                  currentUserId: currentUserId,
                  onTap: () => _openDetail(game),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip('Alle', GameFilter.all),
          const SizedBox(width: 8),
          _filterChip('Meine', GameFilter.interested),
          const SizedBox(width: 8),
          _filterChip('Engpass', GameFilter.bottleneck),
        ],
      ),
    );
  }

  Widget _filterChip(String label, GameFilter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.tanGold : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.tanGold : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _openDetail(Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(
          game: game,
          currentUserId: currentUserId,
          participants: mockParticipants,
          onGameUpdated: (updated) {
            setState(() {
              final idx = _games.indexWhere((g) => g.id == updated.id);
              if (idx >= 0) _games[idx] = updated;
            });
          },
        ),
      ),
    );
  }
}
