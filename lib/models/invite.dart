import 'transaction.dart';

enum InviteStatus {
  active,
  revoked,
  expired,
  unknown,
}

enum InviteTransactionSubmissionStatus {
  pending,
  approved,
  rejected,
  failed,
  unknown,
}

enum InviteTransactionSubmissionDecision {
  approve,
  reject,
}

class InviteModel {
  final int id;
  final String token;
  final InviteStatus status;
  final DateTime? expiresAt;
  final int invitedByUserId;
  final int accountId;
  final String accountName;
  final int categoryId;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? activatedAt;
  final DateTime? revokedAt;

  InviteModel(
    this.id,
    this.token,
    this.status,
    this.expiresAt,
    this.invitedByUserId,
    this.accountId,
    this.accountName,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
    this.activatedAt,
    this.revokedAt,
  );

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      json['id'] ?? 0,
      json['token'] ?? '',
      InviteParsers.parseInviteStatus(json['status']),
      InviteParsers.parseDateTime(json['expiresAt']),
      json['invitedByUserId'] ?? 0,
      json['accountId'] ?? 0,
      json['accountName'] ?? '',
      json['categoryId'] ?? 0,
      json['categoryName'] ?? '',
      InviteParsers.parseDateTime(json['createdAt']) ?? DateTime.now(),
      InviteParsers.parseDateTime(json['updatedAt']) ?? DateTime.now(),
      InviteParsers.parseDateTime(json['activatedAt']),
      InviteParsers.parseDateTime(json['revokedAt']),
    );
  }

  bool get isRevocable => status == InviteStatus.active;
}

class PublicInviteModel {
  final String token;
  final InviteStatus status;
  final DateTime? expiresAt;
  final int accountId;
  final String accountName;
  final int categoryId;
  final String categoryName;

  PublicInviteModel(
    this.token,
    this.status,
    this.expiresAt,
    this.accountId,
    this.accountName,
    this.categoryId,
    this.categoryName,
  );

  factory PublicInviteModel.fromJson(Map<String, dynamic> json) {
    return PublicInviteModel(
      json['token'] ?? '',
      InviteParsers.parseInviteStatus(json['status']),
      InviteParsers.parseDateTime(json['expiresAt']),
      json['accountId'] ?? 0,
      json['accountName'] ?? '',
      json['categoryId'] ?? 0,
      json['categoryName'] ?? '',
    );
  }

  bool get isActive => status == InviteStatus.active;
}

class InviteTransactionSubmissionModel {
  final int id;
  final int inviteId;
  final InviteTransactionSubmissionStatus status;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType transactionType;
  final int accountId;
  final int categoryId;
  final int? createdTransactionId;
  final String failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;

  InviteTransactionSubmissionModel(
    this.id,
    this.inviteId,
    this.status,
    this.description,
    this.amount,
    this.date,
    this.transactionType,
    this.accountId,
    this.categoryId,
    this.createdTransactionId,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
    this.processedAt,
  );

  factory InviteTransactionSubmissionModel.fromJson(Map<String, dynamic> json) {
    return InviteTransactionSubmissionModel(
      json['id'] ?? 0,
      json['inviteId'] ?? 0,
      InviteParsers.parseSubmissionStatus(json['status']),
      json['description'] ?? '',
      double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      InviteParsers.parseDateTime(json['date']) ?? DateTime.now(),
      TransactionModel.parse(json['transactionType'] ?? 1, categoryName: null),
      json['accountId'] ?? 0,
      json['categoryId'] ?? 0,
      json['createdTransactionId'],
      json['failureReason'] ?? '',
      InviteParsers.parseDateTime(json['createdAt']) ?? DateTime.now(),
      InviteParsers.parseDateTime(json['updatedAt']) ?? DateTime.now(),
      InviteParsers.parseDateTime(json['processedAt']),
    );
  }

  bool get isPending => status == InviteTransactionSubmissionStatus.pending;
}

class CreateInviteRequest {
  final int accountId;
  final int categoryId;
  final DateTime? expiresAt;

  CreateInviteRequest({
    required this.accountId,
    required this.categoryId,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'categoryId': categoryId,
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
    };
  }
}

class CreateInviteTransactionSubmissionRequest {
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType transactionType;

  CreateInviteTransactionSubmissionRequest({
    required this.description,
    required this.amount,
    required this.date,
    required this.transactionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'transactionType': transactionType == TransactionType.Income ? 0 : 1,
    };
  }
}

class ProcessInviteTransactionSubmissionItemRequest {
  final int id;
  final InviteTransactionSubmissionDecision decision;
  final String? failureReason;

  ProcessInviteTransactionSubmissionItemRequest({
    required this.id,
    required this.decision,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'decision': decision == InviteTransactionSubmissionDecision.approve ? 0 : 1,
      'failureReason': failureReason,
    };
  }
}

class InviteParsers {
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }

  static InviteStatus parseInviteStatus(dynamic value) {
    switch (value) {
      case 0:
        return InviteStatus.active;
      case 1:
        return InviteStatus.revoked;
      case 2:
        return InviteStatus.expired;
      default:
        return InviteStatus.unknown;
    }
  }

  static InviteTransactionSubmissionStatus parseSubmissionStatus(dynamic value) {
    switch (value) {
      case 0:
        return InviteTransactionSubmissionStatus.pending;
      case 1:
        return InviteTransactionSubmissionStatus.approved;
      case 2:
        return InviteTransactionSubmissionStatus.rejected;
      case 3:
        return InviteTransactionSubmissionStatus.failed;
      default:
        return InviteTransactionSubmissionStatus.unknown;
    }
  }
}
