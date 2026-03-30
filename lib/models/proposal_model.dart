import 'package:flutter/material.dart';

enum ProposalStatus {
  open,
  approved,
  rejected,
  closed,
  unknown
}
extension ProposalStatusExt on ProposalStatus {
  static ProposalStatus fromString(String? s){
    final value = (s ?? '').trim().toLowerCase();
    switch (value){
      case 'open':
      return ProposalStatus.open;
      case 'approved':
      return ProposalStatus.approved;
      case 'rejected':
      return ProposalStatus.rejected;
      case 'closed':
      return ProposalStatus.closed;
      default:
      return ProposalStatus.unknown;
    }
  }
  String get label {
    switch (this){
      case ProposalStatus.open:
      return 'Open';
      case ProposalStatus.approved:
      return 'Approved';
      case ProposalStatus.rejected:
      return 'Rejected';
      case ProposalStatus.closed:
      return 'Closed';
      default:
      return 'Unknown';
    }
  }
  Color get color {
    switch (this) {
      case ProposalStatus.open:
      return const Color(0xFF3DBD71);
      case ProposalStatus.approved:
      return const Color(0xFFC9A84C);
      case ProposalStatus.rejected:
      return const Color(0xFFE05252);
      case ProposalStatus.closed:
      return const Color(0xFF4A90D9);
      default:
      return const Color(0xFF5A7A62);
    }
  }
  Color get bgColor => color;
  IconData get icon {
  switch (this) {
    case ProposalStatus.open:
    return Icons.how_to_vote_rounded;
    case ProposalStatus.approved:
    return Icons.verified_rounded;
    case ProposalStatus.rejected:
    return Icons.cancel_rounded;
    case ProposalStatus.closed:
    return Icons.lock_rounded;
    default:
    return Icons.help_outline_rounded;
  }
  }
}
class Proposal {
  final int id;
  final String title;
  final String description;
  final ProposalStatus status;
  final int yesVotes;
  final int noVotes;
  final String createdAt;
  final bool isMine;
  final bool? myVote;
  final int commentCount;
  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.yesVotes,
    required this.noVotes,
    required this.createdAt,
    required this.isMine,
    this.myVote,
    this.commentCount = 0
  });
  int get totalVotes => yesVotes + noVotes;
  double get yesPercent => totalVotes == 0 ? 0 : yesVotes / totalVotes;
  bool get hasVoted => myVote != null;
  factory Proposal.fromJson(Map<String, dynamic> j) => Proposal(
    id: (j['proposal_id'] as num).toInt(), 
    title: (j['title'] ?? '').toString(), 
    description: (j['description'] ?? '').toString(), 
    status: ProposalStatusExt.fromString(j['status']?.toString()), 
    yesVotes: ((j['yes_votes'] ?? 0) as num).toInt(), 
    noVotes: ((j['no_votes'] ?? 0) as num).toInt(), 
    createdAt: (j['created_at'] ?? '').toString(), 
    isMine: j['is_mine'] == true || j['is_mine'] == 1,
    myVote: j['my_vote'] as bool?,
    commentCount: ((j['comment_count'] ?? 0) as num).toInt()
  );
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    }
    catch (_){
      return createdAt;
    }
  }
  Proposal copyWith({
    bool? myVote,
    int? yesVotes,
    int? noVotes,
    ProposalStatus? status,
    int? commentCount
  }) {
    return Proposal(
      id: id, 
      title: title, 
      description: description, 
      status: status ?? this.status, 
      yesVotes: yesVotes ?? this.yesVotes, 
      noVotes: noVotes ?? this.noVotes, 
      createdAt: createdAt, 
      isMine: isMine,
      myVote: myVote ?? this.myVote,
      commentCount: commentCount ?? this.commentCount
      );
  }
}