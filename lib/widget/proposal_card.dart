import 'package:flutter/material.dart';
import 'package:frontend/models/proposal_model.dart';

class ProposalCard extends StatefulWidget {
  final Proposal proposal;
  final VoidCallback onVoteYes;
  final VoidCallback onVoteNo;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onVoteYes,
    required this.onVoteNo,
  });

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController barAnim;
  late Animation<double> barValue;

  static const Color _card = Color(0xFF111D13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F5F1);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF5A7A62);
  static const Color _red = Color(0xFFE05252);

  @override
  void initState() {
    super.initState();

    barAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _configureBarAnimation(
      begin: 0,
      end: widget.proposal.yesPercent,
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        barAnim.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProposalCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.proposal.yesPercent != widget.proposal.yesPercent) {
      final currentValue = barValue.value;

      _configureBarAnimation(
        begin: currentValue,
        end: widget.proposal.yesPercent,
      );

      barAnim
        ..reset()
        ..forward();
    }
  }

  void _configureBarAnimation({
    required double begin,
    required double end,
  }) {
    barValue = Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: barAnim,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    barAnim.dispose();
    super.dispose();
  }

  bool get canVote =>
      widget.proposal.status == ProposalStatus.open &&
      !widget.proposal.isMine;

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: p.status == ProposalStatus.approved
              ? _gold.withOpacity(0.30)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTopSection(p),
          buildVoteBar(p),
          buildBottomRow(p),
        ],
      ),
    );
  }

  Widget buildTopSection(Proposal p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              statusBadge(p.status),
              if (p.isMine) ...[
                const SizedBox(width: 8),
                mineBadge(),
              ],
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: _text3,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${p.commentCount}',
                    style: const TextStyle(
                      color: _text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text1,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text2,
              fontSize: 13.2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget statusBadge(ProposalStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.color.withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            color: status.color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget mineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _gold.withOpacity(0.28),
        ),
      ),
      child: const Text(
        'My Proposal',
        style: TextStyle(
          color: _gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildVoteBar(Proposal p) {
    final totalStr = p.totalVotes == 0
        ? 'No votes yet'
        : '${p.yesVotes} Yes · ${p.noVotes} No · ${p.totalVotes} total';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: _surf2,
                ),
                AnimatedBuilder(
                  animation: barValue,
                  builder: (_, __) => FractionallySizedBox(
                    widthFactor: barValue.value.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: p.yesPercent > 0.6
                              ? [_green, _greenL]
                              : p.yesPercent > 0.4
                                  ? [_gold, const Color(0xFFE8B84B)]
                                  : [_red.withOpacity(0.85), _red],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  totalStr,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text3,
                    fontSize: 11.5,
                  ),
                ),
              ),
              if (p.totalVotes > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${(p.yesPercent * 100).toStringAsFixed(0)}% support',
                  style: TextStyle(
                    color: p.yesPercent >= 0.5 ? _greenL : _red,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget buildBottomRow(Proposal p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _surf2.withOpacity(0.60),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(19),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: _text3,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                p.formattedDate,
                style: const TextStyle(
                  color: _text3,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (canVote) ...[
            voteButton(
              label: 'No',
              icon: Icons.thumb_down_alt_rounded,
              active: p.myVote == false,
              activeColor: _red,
              onTap: widget.onVoteNo,
            ),
            const SizedBox(width: 8),
            voteButton(
              label: 'Yes',
              icon: Icons.thumb_up_alt_rounded,
              active: p.myVote == true,
              activeColor: _greenL,
              onTap: widget.onVoteYes,
            ),
          ] else if (p.isMine && p.status == ProposalStatus.open) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: const Text(
                'Your proposal',
                style: TextStyle(
                  color: _text3,
                  fontSize: 11.5,
                ),
              ),
            ),
          ] else if (p.status == ProposalStatus.approved) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _gold.withOpacity(0.30),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: _gold,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Approved',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (p.status == ProposalStatus.rejected) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _red.withOpacity(0.30),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: _red,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Rejected',
                    style: TextStyle(
                      color: _red,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget voteButton({
    required String label,
    required IconData icon,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.14) : _surf2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active ? activeColor.withOpacity(0.45) : _border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? activeColor : _text3,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? activeColor : _text3,
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}