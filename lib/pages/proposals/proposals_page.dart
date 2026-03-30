import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/proposal_model.dart';
import 'package:frontend/pages/proposals/new_proposal_sheet.dart';
import 'package:frontend/services/proposal_service.dart';
import 'package:frontend/widget/proposal_card.dart';

class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF060E08);
  static const Color _surface = Color(0xFF0E1A10);
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

  final List<String> filters = ['All', 'Open', 'Mine', 'Approved'];

  int activeFilter = 0;
  List<Proposal> proposals = [];
  bool loading = true;
  String? error;

  late AnimationController headerAnim;
  late AnimationController listAnim;
  late Animation<double> headerFade;
  late Animation<Offset> headerSlide;

  @override
  void initState() {
    super.initState();

    headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    headerFade = CurvedAnimation(
      parent: headerAnim,
      curve: Curves.easeOut,
    );

    headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: headerAnim,
        curve: Curves.easeOut,
      ),
    );

    headerAnim.forward();
    load();
  }

  @override
  void dispose() {
    headerAnim.dispose();
    listAnim.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    final result = await ProposalService.getProposals();

    if (!mounted) return;

    setState(() {
      loading = false;
      if (result.success) {
        proposals = result.proposals;
        listAnim.forward(from: 0);
      } else {
        error = result.errorMessage;
      }
    });
  }

  List<Proposal> get filtered {
    switch (activeFilter) {
      case 1:
        return proposals
            .where((p) => p.status == ProposalStatus.open)
            .toList();
      case 2:
        return proposals.where((p) => p.isMine).toList();
      case 3:
        return proposals
            .where((p) => p.status == ProposalStatus.approved)
            .toList();
      default:
        return proposals;
    }
  }

  int countForFilter(int i) {
    switch (i) {
      case 0:
        return proposals.length;
      case 1:
        return proposals
            .where((p) => p.status == ProposalStatus.open)
            .length;
      case 2:
        return proposals.where((p) => p.isMine).length;
      case 3:
        return proposals
            .where((p) => p.status == ProposalStatus.approved)
            .length;
      default:
        return 0;
    }
  }

  Future<void> handleVote(Proposal p, bool voteYes) async {
    setState(() {
      final idx = proposals.indexWhere((x) => x.id == p.id);
      if (idx == -1) return;

      final old = proposals[idx];
      final wasYes = old.myVote == true;
      final wasNo = old.myVote == false;

      int yes = old.yesVotes;
      int no = old.noVotes;

      if (voteYes) {
        if (wasYes) {
          yes--;
          proposals[idx] = old.copyWith(myVote: null, yesVotes: yes);
          return;
        }
        if (wasNo) no--;
        proposals[idx] = old.copyWith(
          myVote: true,
          yesVotes: yes + 1,
          noVotes: no,
        );
      } else {
        if (wasNo) {
          no--;
          proposals[idx] = old.copyWith(myVote: null, noVotes: no);
          return;
        }
        if (wasYes) yes--;
        proposals[idx] = old.copyWith(
          myVote: false,
          yesVotes: yes,
          noVotes: no + 1,
        );
      }
    });

    final result = await ProposalService.vote(
      proposalId: p.id,
      voteYes: voteYes,
    );

    if (result.success && mounted && result.yesVotes != null) {
      setState(() {
        final idx = proposals.indexWhere((x) => x.id == p.id);
        if (idx != -1) {
          proposals[idx] = proposals[idx].copyWith(
            yesVotes: result.yesVotes,
            noVotes: result.noVotes,
            myVote: result.myVote,
          );
        }
      });
    } else if (!result.success && mounted) {
      await load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Vote failed.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void openNewProposal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewProposalSheet(
        onCreated: (proposal) {
          setState(() {
            proposals.insert(0, proposal);
            activeFilter = 0;
          });
          listAnim.forward(from: 0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _green.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _gold.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                buildHeader(),
                buildFilterRow(),
                if (!loading && error == null) buildStatsBanner(),
                Expanded(child: buildBody()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

  Widget buildHeader() {
    return SlideTransition(
      position: headerSlide,
      child: FadeTransition(
        opacity: headerFade,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _surf2,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _text2,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proposals',
                      style: TextStyle(
                        color: _text1,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Submit a proposal for your community',
                      style: TextStyle(
                        color: _text3,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: openNewProposal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2D9B5A),
                        Color(0xFF1E7A42),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: List.generate(filters.length, (i) {
            final active = i == activeFilter;
            final count = countForFilter(i);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => activeFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: active ? _green : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _green.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filters[i],
                          style: TextStyle(
                            color: active ? Colors.white : _text3,
                            fontSize: 12.5,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withOpacity(0.22)
                                  : _surf2,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: active ? Colors.white : _text2,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildStatsBanner() {
    final open =
        proposals.where((p) => p.status == ProposalStatus.open).length;
    final approved =
        proposals.where((p) => p.status == ProposalStatus.approved).length;
    final totalVotes = proposals.fold<int>(0, (s, p) => s + p.totalVotes);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          statPill('$open', 'Active', _greenL),
          const SizedBox(width: 10),
          statPill('$approved', 'Approved', _gold),
          const SizedBox(width: 10),
          statPill('$totalVotes', 'Total Votes', _text2),
        ],
      ),
    );
  }

  Widget statPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _text3,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D9B5A),
          strokeWidth: 2.5,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: _text3,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text2,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = filtered;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: _text3,
                size: 56,
              ),
              const SizedBox(height: 14),
              Text(
                activeFilter == 2
                    ? "You haven't submitted any proposals yet"
                    : 'No proposals found',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to share an idea for your community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text3,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _green,
      backgroundColor: _card,
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: items.length,
        itemBuilder: (_, i) => AnimatedBuilder(
          animation: listAnim,
          builder: (_, child) {
            final delay = (i * 0.08).clamp(0.0, 0.6);
            final end = (delay + 0.4).clamp(0.0, 1.0);
            final t =
                ((listAnim.value - delay) / (end - delay)).clamp(0.0, 1.0);
            final curve = Curves.easeOut.transform(t);

            return Opacity(
              opacity: curve,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - curve)),
                child: child,
              ),
            );
          },
          child: ProposalCard(
            proposal: items[i],
            onVoteYes: () => handleVote(items[i], true),
            onVoteNo: () => handleVote(items[i], false),
          ),
        ),
      ),
    );
  }

  Widget buildBottomNav() {
    const navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.description_rounded, 'label': 'Request'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1509),
        border: Border(
          top: BorderSide(color: Color(0xFF1E3A24)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(
              navItems.length,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i == 0) Navigator.pushNamed(context, '/home');
                    if (i == 1) Navigator.pushNamed(context, '/requests');
                    if (i == 2) Navigator.pushNamed(context, '/profile');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navItems[i]['icon'] as IconData,
                        color: _text3,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        navItems[i]['label'] as String,
                        style: const TextStyle(
                          color: _text3,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}