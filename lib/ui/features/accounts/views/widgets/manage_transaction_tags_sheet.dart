import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/domain/models/tag.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/data/repositories/tag.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/ui/features/home/views/shared/tag_select/tag_dialog_selection.dart';

const int kMaxTagsPerTransaction = 10;

class ManageTransactionTagsSheet extends StatefulWidget {
  final TransactionModel transaction;
  ManageTransactionTagsSheet({required this.transaction});

  @override
  State<ManageTransactionTagsSheet> createState() =>
      _ManageTransactionTagsSheetState();
}

class _ManageTransactionTagsSheetState
    extends State<ManageTransactionTagsSheet> {
  final TagRepository _tagRepository = GetIt.I<TagRepository>();
  final TransactionRepository _transactionRepository =
      GetIt.I<TransactionRepository>();

  late List<TagModel> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.transaction.tags
        .map((t) => TagModel(t.id, t.name))
        .toList();
  }

  Future<void> _openTagDialog() async {
    final result = await showDialog<List<TagModel>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return TagDialogSelection(
          onSelectedTagsChanged: (_) {},
          multipleSelection: true,
          selectedTags: _selected,
          maxSelection: kMaxTagsPerTransaction,
        );
      },
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _selected = result;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    try {
      await _transactionRepository.applyTagsToTransaction(
          widget.transaction.id, _selected.map((t) => t.name).toList());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.label_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.manageTransactionTags,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              localizations.transactionTagsTitle(widget.transaction.name),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openTagDialog,
              icon: const Icon(Icons.edit),
              label: Text(localizations.selectTags),
            ),
            const SizedBox(height: 12),
            _selected.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      localizations.noTags,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selected
                        .map((t) => Chip(
                              label: Text(t.name),
                              onDeleted: () {
                                setState(() {
                                  _selected.removeWhere(
                                      (existing) => existing.id == t.id);
                                });
                              },
                            ))
                        .toList(),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(localizations.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
