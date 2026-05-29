import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/invite.dart';

class PublicInviteService {
  final Uri backendEndpoint = Uri.https('www.ramiro-di-rico.dev', 'homemanagementapi/api/');

  Future<PublicInviteModel> getByToken(String token) async {
    final response = await http.get(
      backendEndpoint.resolve('public/invites/$token'),
      headers: _headers(),
    );

    _ensureSuccessful(response, 'fetch invite');
    return PublicInviteModel.fromJson(json.decode(response.body));
  }

  Future<InviteTransactionSubmissionModel> createSubmission(
    String token,
    CreateInviteTransactionSubmissionRequest request,
  ) async {
    final response = await http.post(
      backendEndpoint.resolve('public/invites/$token/transactions'),
      headers: _headers(),
      body: json.encode(request.toJson()),
    );

    _ensureSuccessful(response, 'create submission');
    return InviteTransactionSubmissionModel.fromJson(json.decode(response.body));
  }

  Future<InviteTransactionSubmissionModel> getSubmission(String token, int id) async {
    final response = await http.get(
      backendEndpoint.resolve('public/invites/$token/transactions/$id'),
      headers: _headers(),
    );

    _ensureSuccessful(response, 'fetch submission');
    return InviteTransactionSubmissionModel.fromJson(json.decode(response.body));
  }

  Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void _ensureSuccessful(http.Response response, String operation) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to $operation.');
    }
  }
}
