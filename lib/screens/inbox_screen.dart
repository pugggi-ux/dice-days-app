import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/game.dart';
import '../services/mock_data.dart';
import '../widgets/game_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late List<Game> _inboxGames;
  String? _snappedGameId;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    _inboxGames = mockGames.where((g) =>
      !g.isInterestedBy(currentUserId) &&
      !g.isExplainedBy(currentUserId) &&
      !g.isHiddenBy(currentUserId)
    ).toList();
  }

  void _markInterest(Game game) {
    _showToast('Interesse vermerkt: ${game.name}', AppColors.success, game);
    setState(() => _inboxGames.removeWhere((g) => g.id == game.id));
  }

  void _markInterestAndExplanation(Game game) {
    _showToast('Interesse + Erklärbedarf: ${game.name}', AppColors.success, game);
    setState(() => _inboxGames.removeWhere((g) => g.id == game.id));
  }

  void _hide(Game game) {
    _showToast('Ausgeblendet: ${game.name}', AppColors.neutral, game);
    setState(() => _inboxGames.removeWhere((g) => g.id == game.id));
  }

  void _undo(Game game) {
    setState(() {
      _inboxGames.add(game);
      _snappedGameId = null;
    });
  }

  void _showToast(String message, Color color, Game game) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(milliseconds: 3500),
      action: SnackBarAction(
        label: 'Rückgängig',
        textColor: Colors.white,
        onPressed: () => _undo(game),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Inbox', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _showInfo = !_showInfo),
              child: Icon(
                _showInfo ? Icons.info : Icons.info_outline,
                size: 20,
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showInfo)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tanGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Wische nach rechts für Interesse, nach links zum Ausblenden. '
                'Beim Einrasten kannst du auch Erklärbedarf markieren.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          Expanded(
            child: _inboxGames.isEmpty
                ? const Center(
                    child: Text(
                      'Keine neuen Spiele',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _inboxGames.length,
                    itemBuilder: (context, index) {
                      final game = _inboxGames[index];
                      return _SwipeableGameCard(
                        key: ValueKey(game.id),
                        game: game,
                        isSnapped: _snappedGameId == game.id,
                        onSnap: () => setState(() => _snappedGameId = game.id),
                        onUnsnap: () {
                          if (_snappedGameId == game.id) {
                            setState(() => _snappedGameId = null);
                          }
                        },
                        onInterest: () => _markInterest(game),
                        onInterestAndExplanation: () => _markInterestAndExplanation(game),
                        onHide: () => _hide(game),
                        shouldReset: _snappedGameId != null && _snappedGameId != game.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SwipeableGameCard extends StatefulWidget {
  final Game game;
  final bool isSnapped;
  final bool shouldReset;
  final VoidCallback onSnap;
  final VoidCallback onUnsnap;
  final VoidCallback onInterest;
  final VoidCallback onInterestAndExplanation;
  final VoidCallback onHide;

  const _SwipeableGameCard({
    super.key,
    required this.game,
    required this.isSnapped,
    required this.shouldReset,
    required this.onSnap,
    required this.onUnsnap,
    required this.onInterest,
    required this.onInterestAndExplanation,
    required this.onHide,
  });

  @override
  State<_SwipeableGameCard> createState() => _SwipeableGameCardState();
}

class _SwipeableGameCardState extends State<_SwipeableGameCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _snapped = false;
  late AnimationController _animController;
  late Animation<double> _animOffset;

  static const _minThreshold = 30.0;
  static const _interestWagonWidth = 76.0;
  static const _explanationWagonWidth = 76.0;
  static const _fullThreshold = 200.0;
  static const _hideThreshold = -100.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animOffset = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addListener(() => setState(() => _dragOffset = _animOffset.value));
  }

  @override
  void didUpdateWidget(_SwipeableGameCard old) {
    super.didUpdateWidget(old);
    if (widget.shouldReset && _snapped) {
      _animateTo(0);
      _snapped = false;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animOffset = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragOffset += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffset >= _fullThreshold) {
      widget.onInterest();
      return;
    }
    if (_dragOffset <= _hideThreshold) {
      widget.onHide();
      return;
    }
    if (_dragOffset >= _minThreshold) {
      final snapTo = _dragOffset >= _interestWagonWidth + _explanationWagonWidth / 2
          ? _interestWagonWidth + _explanationWagonWidth
          : _interestWagonWidth;
      _animateTo(snapTo);
      _snapped = true;
      widget.onSnap();
    } else if (_dragOffset <= -_minThreshold) {
      _animateTo(0);
      _snapped = false;
    } else {
      _animateTo(0);
      _snapped = false;
      widget.onUnsnap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          if (_dragOffset > 0) _buildRightWagons(),
          if (_dragOffset < 0) _buildLeftBackground(),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GameCard(
              game: widget.game,
              currentUserId: currentUserId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightWagons() {
    return Positioned.fill(
      child: Row(
        children: [
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _snapped ? widget.onInterest : null,
            child: Container(
              width: _interestWagonWidth,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 22),
                  SizedBox(height: 2),
                  Text('Interesse', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          if (_dragOffset > _interestWagonWidth)
            GestureDetector(
              onTap: _snapped ? widget.onInterestAndExplanation : null,
              child: Container(
                width: (_dragOffset - _interestWagonWidth).clamp(0.0, _explanationWagonWidth),
                decoration: BoxDecoration(
                  color: AppColors.explainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: _dragOffset - _interestWagonWidth > 40
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help_outline, color: Colors.white, size: 22),
                          SizedBox(height: 2),
                          Text('Erklärung', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftBackground() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.neutral.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, color: AppColors.neutral, size: 22),
            SizedBox(height: 2),
            Text('Ausblenden', style: TextStyle(color: AppColors.neutral, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
