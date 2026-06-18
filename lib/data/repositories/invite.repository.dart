import 'package:flutter/material.dart';

import 'package:home_management_app/domain/models/invite.dart';
import 'package:home_management_app/data/services/invite.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';

class InviteRepository extends ChangeNotifier {
  final InviteService inviteService;
  final NotifierService notifierService;

  final List<InviteModel> invites = [];

  InviteRepository({
    required this.inviteService,
    required this.notifierService,
  });

  Future load() async {
    final result = await inviteService.fetchAll();
    invites
      ..clear()
      ..addAll(result);
    invites.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<InviteModel> create(CreateInviteRequest request) async {
    try {
      final invite = await inviteService.create(request);
      invites.removeWhere((item) => item.id == invite.id);
      invites.insert(0, invite);
      notifyListeners();
      notifierService.notify('Invitation created successfully');
      return invite;
    } catch (ex) {
      notifierService.notify('Failed to create invitation', isError: true);
      rethrow;
    }
  }

  Future<InviteModel> revoke(int inviteId) async {
    try {
      final invite = await inviteService.revoke(inviteId);
      _upsertInvite(invite);
      notifierService.notify('Invitation revoked');
      return invite;
    } catch (ex) {
      notifierService.notify('Failed to revoke invitation', isError: true);
      rethrow;
    }
  }

  Future<void> delete(List<int> inviteIds) async {
    try {
      await inviteService.delete(inviteIds);
      invites.removeWhere((item) => inviteIds.contains(item.id));
      notifyListeners();
      notifierService.notify('Invitation${inviteIds.length > 1 ? 's' : ''} deleted');
    } catch (ex) {
      notifierService.notify('Failed to delete invitation${inviteIds.length > 1 ? 's' : ''}', isError: true);
      rethrow;
    }
  }

  Future<InviteModel> getById(int inviteId) async {
    final invite = await inviteService.getById(inviteId);
    _upsertInvite(invite);
    return invite;
  }

  Future<List<InviteTransactionSubmissionModel>> getTransactions(int inviteId) {
    return inviteService.getTransactions(inviteId);
  }

  Future<List<InviteTransactionSubmissionModel>> processSubmissions(
    int inviteId,
    List<ProcessInviteTransactionSubmissionItemRequest> submissions,
  ) async {
    try {
      final result = await inviteService.processSubmissions(inviteId, submissions);
      notifierService.notify('Submissions processed successfully');
      return result;
    } catch (ex) {
      notifierService.notify('Failed to process submissions', isError: true);
      rethrow;
    }
  }

  void _upsertInvite(InviteModel invite) {
    invites.removeWhere((item) => item.id == invite.id);
    invites.insert(0, invite);
    invites.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }
}
