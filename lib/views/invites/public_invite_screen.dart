import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/custom/formatters/localized_number_input_formatter.dart';
import 'package:intl/intl.dart';

import '../../models/invite.dart';
import '../../models/transaction.dart';
import '../../services/endpoints/public_invite.service.dart';

class PublicInviteScreen extends StatefulWidget {
  static const String fullPath = '/public/invites/:token';

  final String token;

  const PublicInviteScreen({super.key, required this.token});

  @override
  State<PublicInviteScreen> createState() => _PublicInviteScreenState();
}

class _PublicInviteScreenState extends State<PublicInviteScreen> {
  final PublicInviteService _publicInviteService = GetIt.I<PublicInviteService>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  PublicInviteModel? _invite;
  InviteTransactionSubmissionModel? _lastSubmission;
  TransactionType _selectedType = TransactionType.Outcome;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadInvite();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInvite() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invite = await _publicInviteService.getByToken(widget.token);
      setState(() {
        _invite = invite;
      });
    } catch (ex) {
      setState(() {
        _errorMessage = 'Invitation not found or unavailable.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    final localeCode = Localizations.localeOf(context).toString();
    final amount = LocalizedNumberInputFormatterHelper.parseDouble(
      _amountController.text.trim(),
      localeCode,
    );

    if (_invite == null || !_invite!.isActive) {
      setState(() {
        _errorMessage = 'This invitation is not active anymore.';
      });
      return;
    }

    if (description.isEmpty) {
      setState(() {
        _errorMessage = 'Description is required.';
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid amount.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final submission = await _publicInviteService.createSubmission(
        widget.token,
        CreateInviteTransactionSubmissionRequest(
          description: description,
          amount: amount,
          date: _selectedDate,
          transactionType: _selectedType,
        ),
      );

      setState(() {
        _lastSubmission = submission;
        _successMessage = 'Submission sent for approval.';
        _descriptionController.clear();
        _amountController.clear();
        _selectedDate = DateTime.now();
        _selectedType = TransactionType.Outcome;
      });
    } catch (ex) {
      setState(() {
        _errorMessage = 'Failed to submit transaction.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invitation),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadInvite,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_errorMessage != null) ...[
                      _buildBanner(_errorMessage!, isError: true),
                      const SizedBox(height: 12),
                    ],
                    if (_successMessage != null) ...[
                      _buildBanner(_successMessage!, isError: false),
                      const SizedBox(height: 12),
                    ],
                    if (_invite != null) ...[
                      _buildInviteHeader(_invite!),
                      const SizedBox(height: 16),
                      _buildSubmissionForm(),
                      if (_lastSubmission != null) ...[
                        const SizedBox(height: 16),
                        _buildSubmissionResult(_lastSubmission!),
                      ],
                    ] else
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(AppLocalizations.of(context)!.invitationUnavailable),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBanner(String message, {required bool isError}) {
    return Material(
      color: isError
          ? Theme.of(context).colorScheme.errorContainer
          : Colors.green.shade800,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }

  Widget _buildInviteHeader(PublicInviteModel invite) {
    final expiresText = invite.expiresAt == null
        ? 'No expiration'
        : DateFormat('dd MMM yyyy, HH:mm').format(invite.expiresAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invite.accountName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.categoryName(invite.categoryName)),
            Text(AppLocalizations.of(context)!.statusLabel(_inviteStatusLabel(invite.status))),
            Text(AppLocalizations.of(context)!.expiresLabel(expiresText)),
            const SizedBox(height: 12),
            SelectableText(widget.token),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionForm() {
    final isActive = _invite?.isActive ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.submitTransaction, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              enabled: isActive && !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: isActive && !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                LocalizedNumberInputFormatter(
                  locale: Localizations.localeOf(context).toString(),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            DateTimeField(
              enabled: isActive && !_isSubmitting,
              format: DateFormat('dd MMM yyyy'),
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
              initialValue: _selectedDate,
              onShowPicker: (context, currentValue) => showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2100),
              ),
              onChanged: (date) {
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              resetIcon: null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TransactionType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_vert),
              ),
              items: [
                DropdownMenuItem(value: TransactionType.Outcome, child: Text(AppLocalizations.of(context)!.outcome)),
                DropdownMenuItem(value: TransactionType.Income, child: Text(AppLocalizations.of(context)!.income)),
              ],
              onChanged: !isActive || _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedType = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !isActive || _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(AppLocalizations.of(context)!.submitForApproval),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionResult(InviteTransactionSubmissionModel submission) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(submission.description),
        subtitle: Text(
          'Status: ${_submissionStatusLabel(submission.status)}\n'
          'Date: ${DateFormat('dd MMM yyyy').format(submission.date)}',
        ),
        trailing: Text(submission.amount.toStringAsFixed(2)),
      ),
    );
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
