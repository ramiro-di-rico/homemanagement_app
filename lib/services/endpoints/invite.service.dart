import 'dart:convert';

import '../../models/invite.dart';
import '../security/authentication.service.dart';
import 'api.service.factory.dart';

class InviteService {
  final AuthenticationService authenticationService;
  late final ApiServiceFactory apiServiceFactory;
  final String apiName = 'invites';

  InviteService({required this.authenticationService}) {
    apiServiceFactory = ApiServiceFactory(authenticationService: authenticationService);
  }

  Future<List<InviteModel>> fetchAll() async {
    final data = await apiServiceFactory.fetchList(apiName);
    return data.map((item) => InviteModel.fromJson(item)).toList();
  }

  Future<InviteModel> create(CreateInviteRequest request) async {
    final body = json.encode(request.toJson());
    final data = await apiServiceFactory.postWithReturn(apiName, body);
    return InviteModel.fromJson(data);
  }

  Future<InviteModel> getById(int id) async {
    final data = await apiServiceFactory.apiGet('$apiName/$id');
    return InviteModel.fromJson(data);
  }

  Future<List<InviteTransactionSubmissionModel>> getTransactions(int inviteId) async {
    final data = await apiServiceFactory.fetchList('$apiName/$inviteId/transactions');
    return data.map((item) => InviteTransactionSubmissionModel.fromJson(item)).toList();
  }

  Future<InviteModel> revoke(int inviteId) async {
    final data = await apiServiceFactory.apiPut('$apiName/$inviteId/revoke', '{}');
    return InviteModel.fromJson(data);
  }

  Future<void> delete(List<int> inviteIds) async {
    final body = json.encode({
      'ids': inviteIds,
      'deleteExpired': true,
    });
    await apiServiceFactory.apiDelete(apiName, '', body: body);
  }

  Future<List<InviteTransactionSubmissionModel>> processSubmissions(
    int inviteId,
    List<ProcessInviteTransactionSubmissionItemRequest> submissions,
  ) async {
    final body = json.encode({
      'submissions': submissions.map((item) => item.toJson()).toList(),
    });

    final data = await apiServiceFactory.apiPut('$apiName/$inviteId/transactions/process', body);
    return (data as List)
        .map((item) => InviteTransactionSubmissionModel.fromJson(item))
        .toList();
  }
}
