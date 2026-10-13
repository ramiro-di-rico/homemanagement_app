import 'package:flutter/material.dart';

import 'package:home_management_app/data/models/document_transaction_draft.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

/// Lets the user pick which of several document previews to apply to the
/// add-transaction form, when more than one file produced a usable draft.
Future<DocumentTransactionDraft?> showDocumentPreviewPicker(
    BuildContext context, List<DocumentTransactionPreview> previews) {
  final strings = AppLocalizations.of(context)!;
  return showModalBottomSheet<DocumentTransactionDraft>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(strings.selectDocumentPreview,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...previews.map((preview) => ListTile(
                title: Text(preview.draft!.name),
                subtitle: Text(preview.fileName),
                trailing: Text(preview.draft!.amount.toStringAsFixed(2)),
                onTap: () => Navigator.of(context).pop(preview.draft),
              )),
        ],
      ),
    ),
  );
}
