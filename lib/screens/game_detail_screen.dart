import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/game.dart';
import '../models/participant.dart';
import '../widgets/sweet_spot_indicator.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;
  final String currentUserId;
  final List<Participant> participants;
  final ValueChanged<Game> onGameUpdated;

  const GameDetailScreen({
    super.key,
    required this.game,
    required this.currentUserId,
    required this.participants,
    required this.onGameUpdated,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Game _game;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  void _update(Game updated) {
    setState(() => _game = updated);
    widget.onGameUpdated(updated);
  }

  Participant? _findParticipant(String id) {
    try {
      return widget.participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInterested = _game.isInterestedBy(widget.currentUserId);
    final isExplainer = _game.isExplainedBy(widget.currentUserId);
    final needsExplanation = _game.needsExplanationBy(widget.currentUserId);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (_game.bottleneckText != null) _buildBottleneck(),
          if (isExplainer)
            _buildRoleStatus('Du erklärst dieses Spiel', AppColors.explainer),
          if (_game.description != null) ...[
            const SizedBox(height: 16),
            Text(
              _game.description!,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 20),
          _buildRoleColumns(),
          const SizedBox(height: 20),
          _buildInterestList(),
          const SizedBox(height: 24),
          _buildActions(isInterested, isExplainer, needsExplanation),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 80,
            height: 80,
            child: _game.imageUrl != null
                ? Image.network(_game.imageUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_game.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              _metaRow(),
            ],
          ),
        ),
        SweetSpotIndicator(ratio: _game.sweetSpot, size: 44),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.extension, size: 32, color: AppColors.neutral),
    );
  }

  Widget _metaRow() {
    final parts = <String>[];
    if (_game.minPlayers != null && _game.maxPlayers != null) {
      parts.add('${_game.minPlayers}–${_game.maxPlayers} Spieler');
    }
    if (_game.playingTimeMinutes != null) parts.add('${_game.playingTimeMinutes} Min.');
    if (_game.weight != null) parts.add('Komplexität ${_game.weight!.toStringAsFixed(1)}/5');
    return Text(
      parts.join(' · '),
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
    );
  }

  Widget _buildBottleneck() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        _game.bottleneckText!,
        style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildRoleStatus(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRoleColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _roleColumn(
          'Erklärer',
          _game.explainerParticipantIds,
          'Ich erkläre',
          onQuickAdd: () => _addSelfAsExplainer(),
          onAddPerson: () => _showPersonPicker('Erklärer hinzufügen', _game.explainerParticipantIds, (ids) {
            _update(_game.copyWith(explainerParticipantIds: ids));
          }),
          onRemove: (id) {
            final ids = List<String>.from(_game.explainerParticipantIds)..remove(id);
            _update(_game.copyWith(explainerParticipantIds: ids));
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _roleColumn(
          'Lieferant',
          _game.supplierParticipantIds,
          'Ich bringe es mit',
          onQuickAdd: () {
            final ids = List<String>.from(_game.supplierParticipantIds)..add(widget.currentUserId);
            _update(_game.copyWith(supplierParticipantIds: ids));
          },
          onAddPerson: () => _showPersonPicker('Lieferant hinzufügen', _game.supplierParticipantIds, (ids) {
            _update(_game.copyWith(supplierParticipantIds: ids));
          }),
          onRemove: (id) {
            final ids = List<String>.from(_game.supplierParticipantIds)..remove(id);
            _update(_game.copyWith(supplierParticipantIds: ids));
          },
        )),
      ],
    );
  }

  void _addSelfAsExplainer() {
    final explainerIds = List<String>.from(_game.explainerParticipantIds)..add(widget.currentUserId);
    final needsExpIds = List<String>.from(_game.needsExplanationParticipantIds)..remove(widget.currentUserId);
    _update(_game.copyWith(
      explainerParticipantIds: explainerIds,
      needsExplanationParticipantIds: needsExpIds,
    ));
  }

  Widget _roleColumn(
    String title,
    List<String> personIds,
    String quickAddLabel, {
    required VoidCallback onQuickAdd,
    required VoidCallback onAddPerson,
    required ValueChanged<String> onRemove,
  }) {
    final selfAlreadyIn = personIds.contains(widget.currentUserId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onAddPerson,
              child: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.neutral),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (personIds.isEmpty && !selfAlreadyIn)
          OutlinedButton.icon(
            onPressed: onQuickAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(quickAddLabel, style: const TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tanGold,
              side: const BorderSide(color: AppColors.tanGold),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ...personIds.map((id) {
          final p = _findParticipant(id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _personChip(p?.nickname ?? id, id == widget.currentUserId, () => onRemove(id)),
          );
        }),
      ],
    );
  }

  Widget _personChip(String name, bool isSelf, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelf ? AppColors.tanGold.withValues(alpha: 0.15) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: TextStyle(
            fontSize: 13,
            fontWeight: isSelf ? FontWeight.w600 : FontWeight.w400,
          )),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.neutral),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestList() {
    final interested = _game.interestedParticipantIds;
    final needsExp = _game.needsExplanationParticipantIds;
    final needsExpCount = needsExp.where((id) => interested.contains(id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Interessenten ${interested.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (needsExpCount > 0) ...[
              const SizedBox(width: 6),
              Text(
                '(❔ $needsExpCount)',
                style: const TextStyle(fontSize: 13, color: AppColors.success),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (interested.isEmpty)
          const Text('Noch keine Interessenten', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: interested.map((id) {
              final p = _findParticipant(id);
              final isMe = id == widget.currentUserId;
              final isExplainer = _game.isExplainedBy(id);
              final hasNeed = needsExp.contains(id);
              Color bgColor;
              if (isExplainer) {
                bgColor = AppColors.explainer.withValues(alpha: 0.15);
              } else if (isMe) {
                bgColor = AppColors.tanGold.withValues(alpha: 0.15);
              } else {
                bgColor = const Color(0xFFF5F5F5);
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: isExplainer ? AppColors.explainer : (isMe ? AppColors.tanGold : AppColors.neutral),
                      child: Text(
                        p?.initials ?? '?',
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(p?.nickname ?? id, style: const TextStyle(fontSize: 13)),
                    if (hasNeed) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.help_outline, size: 14, color: AppColors.success),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActions(bool isInterested, bool isExplainer, bool needsExplanation) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isInterested)
          OutlinedButton.icon(
            onPressed: _withdrawInterest,
            icon: const Icon(Icons.heart_broken, size: 18),
            label: const Text('Interesse zurückziehen'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.neutral),
          )
        else
          FilledButton.icon(
            onPressed: _addInterest,
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text('Interesse bekunden'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          ),
        if (isInterested && !isExplainer)
          OutlinedButton.icon(
            onPressed: () => _toggleExplanationNeed(!needsExplanation),
            icon: Icon(
              needsExplanation ? Icons.help : Icons.help_outline,
              size: 18,
            ),
            label: Text(needsExplanation ? 'Erklärbedarf aus' : 'Erklärbedarf an'),
            style: OutlinedButton.styleFrom(
              foregroundColor: needsExplanation ? AppColors.success : AppColors.neutral,
            ),
          ),
      ],
    );
  }

  void _addInterest() {
    final ids = List<String>.from(_game.interestedParticipantIds)..add(widget.currentUserId);
    _update(_game.copyWith(interestedParticipantIds: ids));
  }

  void _withdrawInterest() {
    final intIds = List<String>.from(_game.interestedParticipantIds)..remove(widget.currentUserId);
    final expIds = List<String>.from(_game.explainerParticipantIds)..remove(widget.currentUserId);
    final supIds = List<String>.from(_game.supplierParticipantIds)..remove(widget.currentUserId);
    final needIds = List<String>.from(_game.needsExplanationParticipantIds)..remove(widget.currentUserId);
    _update(_game.copyWith(
      interestedParticipantIds: intIds,
      explainerParticipantIds: expIds,
      supplierParticipantIds: supIds,
      needsExplanationParticipantIds: needIds,
    ));
  }

  void _toggleExplanationNeed(bool on) {
    final ids = List<String>.from(_game.needsExplanationParticipantIds);
    if (on) {
      ids.add(widget.currentUserId);
    } else {
      ids.remove(widget.currentUserId);
    }
    _update(_game.copyWith(needsExplanationParticipantIds: ids));
  }

  void _showPersonPicker(String title, List<String> currentIds, ValueChanged<List<String>> onSave) {
    final selected = Set<String>.from(currentIds);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ...widget.participants.map((p) => CheckboxListTile(
              title: Text(p.nickname),
              value: selected.contains(p.id),
              onChanged: (v) {
                setSheetState(() {
                  if (v == true) {
                    selected.add(p.id);
                  } else {
                    selected.remove(p.id);
                  }
                });
              },
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  onSave(selected.toList());
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.tanGold),
                child: const Text('Übernehmen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
