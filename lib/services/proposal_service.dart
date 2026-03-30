import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/api.dart';
import 'package:frontend/models/proposal_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
class ProposalResult {
  final bool success;
  final List<Proposal> proposals;
  final String? errorMessage;
  const ProposalResult({
    required this.success,
    this.proposals = const [],
    this.errorMessage
  });
}
class ProposalActionResult {
  final bool success;
  final String? message;
  final Proposal? proposal;
  const ProposalActionResult({
    required this.success,
    this.message,
    this.proposal
  });
}
class VoteResult {
  final bool success;
  final String? message;
  final int? yesVotes;
  final int? noVotes;
  final int? totalVotes;
  final bool? myVote;
  const VoteResult({
    required this.success,
    this.message,
    this.yesVotes,
    this.noVotes,
    this.totalVotes,
    this.myVote
  });
}
class ProposalService {
  static Future<Map<String, String>> headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'
    };
  }
  // Get /api/proposals
  static Future<ProposalResult> getProposals() async {
    try {
      final response = await http.get(
        Uri.parse(Api.proposals),
        headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final list = (data['proposals'] as List).map((p) => Proposal.fromJson(p as Map<String, dynamic>)).toList();
        return ProposalResult(
          success: true,
          proposals: list
          );
      }
      return ProposalResult(
        success: false,
        errorMessage: data['message'] as String? ?? 'Failed too load proposals.'
        );
    } on TimeoutException {
      return const ProposalResult(
        success: false,
        errorMessage: 'Connection timed out.'
        );
    } on SocketException{
      return const ProposalResult(
        success: false,
        errorMessage: 'No internet connection.'
        );
    }
    catch (_){
      return const ProposalResult(
        success: false,
        errorMessage: 'Soomething went wrong.'
        );
    }
  }
  // POST /api/proposals
  static Future<ProposalActionResult> createProposal({
    required String title,
    required String description
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Api.proposals),
        headers: await headers(),
        body: jsonEncode({
          'title': title.trim(),
          'description': description.trim()
        })
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && data['success'] == true){
        final proposal = Proposal.fromJson(data['proposal'] as Map<String, dynamic>);
        return ProposalActionResult(
          success: true,
          message: data['message'] as String?,
          proposal: proposal
          );
      }
      return ProposalActionResult(
        success: false,
        message: data['message'] as String? ?? 'Submission failed.'
        );
    } on TimeoutException{
      return const ProposalActionResult(
        success: false,
        message: 'Connection timed out.'
        );
    } on SocketException{
      return const ProposalActionResult(
        success: false,
        message: 'No internet connection.'
        );
    }
    catch (_){
      return const ProposalActionResult(
        success: false,
        message: 'Something went wrong.'
        );
    }
  }
  // POST vote on proposal
  // POST /api/proposals/:id/vote
  static Future<VoteResult> vote({
    required int proposalId,
    required bool voteYes
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.proposals}/$proposalId/vote'),
        headers: await headers(),
        body: jsonEncode({
          'vote': voteYes ? 'yes' : 'no'
        })
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true){
        return VoteResult(
          success: true,
          message: data['message'] as String?,
          yesVotes: (data['yes_votes'] as num?)?.toInt(),
          noVotes: (data['no_votes'] as num?)?.toInt(),
          totalVotes: (data['total_votes'] as num?)?.toInt(),
          myVote: data['my_vote'] as bool? 
          );
      }
      return VoteResult(
        success: false,
        message: data['message'] as String? ?? 'Vote failed'
        );
    } on TimeoutException{
      return const VoteResult(
        success: false,
        message: 'Connection timed out.' 
        );
    } on SocketException{
      return const VoteResult(
        success: false,
        message: 'No internet connection.'
        );
    }
    catch (_){
      return const VoteResult(
        success: false,
        message: 'Something went wrong.'
        );
    }
  }
}