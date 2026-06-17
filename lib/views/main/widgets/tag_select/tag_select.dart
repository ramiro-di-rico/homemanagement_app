import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import '../../../../models/tag.dart';
import 'tag_dialog_selection.dart';

class TagSelect extends StatefulWidget {
  final Function(List<TagModel>) onSelectedTagsChanged;
  final List<TagModel> selectedTags;
  final bool multipleSelection;
  final int? maxSelection;

  TagSelect({
    required this.onSelectedTagsChanged,
    this.multipleSelection = false,
    this.selectedTags = const [],
    this.maxSelection,
  });

  @override
  State<TagSelect> createState() => _TagSelectState();
}

class _TagSelectState extends State<TagSelect> {
  TextEditingController _displayController = TextEditingController();
  List<TagModel> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.selectedTags.toList();
    _refreshDisplay();
  }

  void _refreshDisplay() {
    _displayController.text =
        _selectedTags.map((tag) => tag.name).join(', ');
  }

  void _openDialog() async {
    final result = await showDialog<List<TagModel>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return TagDialogSelection(
          onSelectedTagsChanged: (tags) {},
          multipleSelection: widget.multipleSelection,
          selectedTags: _selectedTags,
          maxSelection: widget.maxSelection,
        );
      },
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _selectedTags = result;
        _refreshDisplay();
      });
      widget.onSelectedTagsChanged(_selectedTags);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _openDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                  controller: _displayController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: widget.multipleSelection
                        ? localizations.selectTags
                        : localizations.selectTag,
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: _openDialog,
                icon: Icon(widget.multipleSelection
                    ? Icons.view_list
                    : Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
