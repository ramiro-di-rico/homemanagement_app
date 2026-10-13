import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:home_management_app/data/models/document_transaction_draft.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

/// Attach-file button for the add-transaction form: pick one or more receipts
/// (image or PDF), send them to the backend and hand the resulting previews
/// to [onPreviews].
class DocumentScanButton extends StatefulWidget {
  final int accountId;
  final ValueChanged<List<DocumentTransactionPreview>> onPreviews;

  const DocumentScanButton(
      {super.key, required this.accountId, required this.onPreviews});

  @override
  State<DocumentScanButton> createState() => _DocumentScanButtonState();
}

class _DocumentScanButtonState extends State<DocumentScanButton> {
  static const _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  bool _processing = false;

  Future<void> _pickAndUpload() async {
    final strings = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _processing = true);
    try {
      final filesByName = <String, Uint8List>{
        for (final file in result.files)
          file.name: await file.xFile.readAsBytes(),
      };
      final previews = await GetIt.I<TransactionRepository>()
          .previewDocumentTransactions(widget.accountId, filesByName);
      if (!mounted) return;
      widget.onPreviews(previews);
    } catch (_) {
      if (!mounted) return;
      GetIt.I<NotifierService>()
          .notify(strings.documentPreviewFailed, isError: true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    if (_processing) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child:
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
      );
    }
    return IconButton(
      icon: const Icon(Icons.attach_file),
      tooltip: strings.attachDocument,
      onPressed: _pickAndUpload,
    );
  }
}
