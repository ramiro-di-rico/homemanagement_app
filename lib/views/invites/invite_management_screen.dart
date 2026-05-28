import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/invite.dart';
import '../../models/transaction.dart';
import '../../services/invite_link_service.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/invite.repository.dart';

class InviteManagementScreen extends StatefulWidget {
  static const String fullPath = '/home_screen/invites';
  static const String path = '/invites';

  const InviteManagementScreen({super.key});

  @override
  State<InviteManagementScreen> createState() => _InviteManagementScreenState();
}

class _InviteManagementScreenState extends State<InviteManagementScreen> {
  final InviteRepository _inviteRepository = GetIt.I<InviteRepository>();
  final AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  final CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  final InviteLinkService _inviteLinkService = GetIt.I<InviteLinkService>();

  AccountModel? _selectedAccount;
  CategoryModel? _selectedCategory;
  DateTime? _selectedExpiry;
  bool _isCreating = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  int? _expandedInviteId;
  String? _message;
  bool _messageIsError = false;

  final Map<int, List<InviteTransactionSubmissionModel>> _submissionsByInvite = {};
  final Map<int, bool> _loadingSubmissions = {};
  final Map<int, Set<int>> _selectedSubmissionIds = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
    _loadInvites();
  }

  void _initializeSelections() {
    final accounts = _accountRepository.accounts;
    final categories = _categoryRepository.getActiveCategories();

    if (accounts.isNotEmpty) {
      _selectedAccount = accounts.first;
    }

    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  Future<void> _loadInvites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _inviteRepository.load();
    } catch (ex) {
      _setMessage('Failed to load invitations.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createInvite() async {
    if (_selectedAccount == null) {
      _setMessage('Select an account first.', isError: true);
      return;
    }

    if (_selectedCategory == null) {
      _setMessage('Select a category first.', isError: true);
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final invite = await _inviteRepository.create(
        CreateInviteRequest(
          accountId: _selectedAccount!.id,
          categoryId: _selectedCategory!.id,
          expiresAt: _selectedExpiry,
        ),
      );
      setState(() {
        _expandedInviteId = invite.id;
      });
      await _loadInviteSubmissions(invite.id);
      _setMessage('Invitation created. Share the link or QR code.');
    } catch (ex) {
      _setMessage('Failed to create invitation.', isError: true);
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  Future<void> _loadInviteSubmissions(int inviteId) async {
    setState(() {
      _loadingSubmissions[inviteId] = true;
    });

    try {
      final submissions = await _inviteRepository.getTransactions(inviteId);
      submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _submissionsByInvite[inviteId] = submissions;
        _selectedSubmissionIds.putIfAbsent(inviteId, () => <int>{});
      });
    } catch (ex) {
      _setMessage('Failed to load submissions.', isError: true);
    } finally {
      setState(() {
        _loadingSubmissions[inviteId] = false;
      });
    }
  }

  Future<void> _toggleExpanded(InviteModel invite, bool expanded) async {
    setState(() {
      _expandedInviteId = expanded ? invite.id : null;
    });

    if (expanded && !_submissionsByInvite.containsKey(invite.id)) {
      await _loadInviteSubmissions(invite.id);
    }
  }

  Future<void> _revokeInvite(InviteModel invite) async {
    try {
      await _inviteRepository.revoke(invite.id);
      _setMessage('Invitation revoked.');
      await _loadInvites();
    } catch (ex) {
      _setMessage('Failed to revoke invitation.', isError: true);
    }
  }

  Future<void> _processSelected(
    InviteModel invite,
    InviteTransactionSubmissionDecision decision,
  ) async {
    final ids = _selectedSubmissionIds[invite.id] ?? <int>{};
    if (ids.isEmpty) {
      _setMessage('Select at least one submission.', isError: true);
      return;
    }

    String? rejectionReason;
    if (decision == InviteTransactionSubmissionDecision.reject) {
      rejectionReason = await _promptFailureReason();
      if (rejectionReason == null) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _inviteRepository.processSubmissions(
        invite.id,
        ids
            .map(
              (id) => ProcessInviteTransactionSubmissionItemRequest(
                id: id,
                decision: decision,
                failureReason: decision == InviteTransactionSubmissionDecision.reject
                    ? rejectionReason
                    : null,
              ),
            )
            .toList(),
      );

      setState(() {
        _selectedSubmissionIds[invite.id]?.clear();
      });

      await _loadInviteSubmissions(invite.id);
      await _inviteRepository.getById(invite.id);
      _setMessage(
        decision == InviteTransactionSubmissionDecision.approve
            ? 'Selected submissions approved.'
            : 'Selected submissions rejected.',
      );
    } catch (ex) {
      _setMessage('Failed to process submissions.', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> _promptFailureReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject submissions'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _copyLink(InviteModel invite) async {
    final url = _inviteLinkService.buildPublicInviteUrl(invite.token);
    await Clipboard.setData(ClipboardData(text: url));
    _setMessage('Invitation link copied.');
  }

  void _showQrCode(InviteModel invite) {
    final url = _inviteLinkService.buildPublicInviteUrl(invite.token);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invitation QR'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                SelectableText(url, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invites = _inviteRepository.invites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInvites,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;

              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 420, child: _buildCreateCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInviteList(invites)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCreateCard(),
                          const SizedBox(height: 12),
                          _buildInviteList(invites),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard() {
    final accounts = _accountRepository.accounts;
    final categories = _categoryRepository.getActiveCategories();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create invitation', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('One account, one invitation. External users submit transactions for later approval.'),
            const SizedBox(height: 16),
            if (_message != null) ...[
              Material(
                color: _messageIsError
                    ? Theme.of(context).colorScheme.errorContainer
                    : Colors.green.shade800,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_message!),
                ),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<AccountModel>(
              initialValue: accounts.any((account) => account.id == _selectedAccount?.id)
                  ? accounts.firstWhere((account) => account.id == _selectedAccount?.id)
                  : null,
              decoration: const InputDecoration(
                labelText: 'Account',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: accounts.map((account) {
                final hasInvite = _inviteRepository.invites.any(
                  (invite) => invite.accountId == account.id && invite.status == InviteStatus.active,
                );

                return DropdownMenuItem<AccountModel>(
                  value: account,
                  enabled: !hasInvite,
                  child: Text(hasInvite ? '${account.name} (already invited)' : account.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CategoryModel>(
              initialValue: categories.any((category) => category.id == _selectedCategory?.id)
                  ? categories.firstWhere((category) => category.id == _selectedCategory?.id)
                  : null,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DateTimeField(
              format: DateFormat('dd MMM yyyy'),
              decoration: const InputDecoration(
                labelText: 'Expiration (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event_available_outlined),
              ),
              initialValue: _selectedExpiry,
              onShowPicker: (context, currentValue) => showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                initialDate: currentValue ?? DateTime.now().add(const Duration(days: 30)),
                lastDate: DateTime(2100),
              ),
              onChanged: (date) {
                setState(() {
                  _selectedExpiry = date;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isCreating ? null : _createInvite,
                    icon: _isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Create invitation'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedExpiry = null;
                    });
                  },
                  child: const Text('Clear date'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteList(List<InviteModel> invites) {
    if (invites.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No invitations yet.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: invites.map(_buildInviteTile).toList(),
    );
  }

  Widget _buildInviteTile(InviteModel invite) {
    final url = _inviteLinkService.buildPublicInviteUrl(invite.token);
    final submissions = _submissionsByInvite[invite.id] ?? [];
    final selectedIds = _selectedSubmissionIds.putIfAbsent(invite.id, () => <int>{});
    final loading = _loadingSubmissions[invite.id] ?? false;
    final pendingCount = submissions.where((item) => item.isPending).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: PageStorageKey('invite_${invite.id}'),
        initiallyExpanded: _expandedInviteId == invite.id,
        onExpansionChanged: (expanded) => _toggleExpanded(invite, expanded),
        title: Text(invite.accountName),
        subtitle: Text(
          '${invite.categoryName}  •  ${_inviteStatusLabel(invite.status)}  •  Pending: $pendingCount',
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () => _copyLink(invite),
              icon: const Icon(Icons.link),
              tooltip: 'Copy link',
            ),
            IconButton(
              onPressed: () => _showQrCode(invite),
              icon: const Icon(Icons.qr_code_2_outlined),
              tooltip: 'Show QR',
            ),
            IconButton(
              onPressed: invite.isRevocable ? () => _revokeInvite(invite) : null,
              icon: const Icon(Icons.block_outlined),
              tooltip: 'Revoke',
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share URL',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Token',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  invite.token,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text('Created: ${DateFormat('dd MMM yyyy, HH:mm').format(invite.createdAt)}'),
                Text('Expires: ${invite.expiresAt == null ? 'No expiration' : DateFormat('dd MMM yyyy, HH:mm').format(invite.expiresAt!)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isProcessing || selectedIds.isEmpty
                    ? null
                    : () => _processSelected(invite, InviteTransactionSubmissionDecision.approve),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve selected'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isProcessing || selectedIds.isEmpty
                    ? null
                    : () => _processSelected(invite, InviteTransactionSubmissionDecision.reject),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject selected'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: loading ? null : () => _loadInviteSubmissions(invite.id),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            )
          else if (submissions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No transaction submissions yet.'),
            )
          else
            Column(
              children: submissions.map((submission) {
                final canSelect = submission.isPending;
                final isSelected = selectedIds.contains(submission.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: !canSelect
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(submission.id);
                            } else {
                              selectedIds.remove(submission.id);
                            }
                          });
                        },
                  title: Text(submission.description),
                  subtitle: Text(
                    '${submission.amount.toStringAsFixed(2)}  •  '
                    '${DateFormat('dd MMM yyyy').format(submission.date)}  •  '
                    '${_submissionStatusLabel(submission.status)}'
                    '${submission.failureReason.isNotEmpty ? '\nReason: ${submission.failureReason}' : ''}',
                  ),
                  secondary: Icon(
                    submission.transactionType == TransactionType.Income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _setMessage(String message, {bool isError = false}) {
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  String _inviteStatusLabel(InviteStatus status) {
    switch (status) {
      case InviteStatus.active:
        return 'Active';
      case InviteStatus.revoked:
        return 'Revoked';
      case InviteStatus.expired:
        return 'Expired';
      case InviteStatus.unknown:
        return 'Unknown';
    }
  }

  String _submissionStatusLabel(InviteTransactionSubmissionStatus status) {
    switch (status) {
      case InviteTransactionSubmissionStatus.pending:
        return 'Pending';
      case InviteTransactionSubmissionStatus.approved:
        return 'Approved';
      case InviteTransactionSubmissionStatus.rejected:
        return 'Rejected';
      case InviteTransactionSubmissionStatus.failed:
        return 'Failed';
      case InviteTransactionSubmissionStatus.unknown:
        return 'Unknown';
    }
  }
}
