import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import '../../../../models/tag.dart';
import '../../../../services/repositories/tag.repository.dart';

class TagDialogSelection extends StatefulWidget {
  final Function(List<TagModel>) onSelectedTagsChanged;
  final List<TagModel> selectedTags;
  final bool multipleSelection;
  final int? maxSelection;

  TagDialogSelection({
    required this.onSelectedTagsChanged,
    this.multipleSelection = false,
    this.selectedTags = const [],
    this.maxSelection,
  });

  @override
  State<TagDialogSelection> createState() => _TagDialogSelectionState();
}

class _TagDialogSelectionState extends State<TagDialogSelection> {
  final TagRepository _tagRepository = GetIt.I<TagRepository>();
  List<TagModel> _selected = [];
  Set<int> _selectedIds = {};
  List<TagModel> _available = [];
  bool _saving = false;
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedTags.toList();
    _selectedIds = _selected.map((t) => t.id).toSet();
    _available = _tagRepository.tags.toList();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  bool _isSelected(TagModel tag) => _selectedIds.contains(tag.id);

  void _toggle(TagModel tag) {
    setState(() {
      if (_isSelected(tag)) {
        _selectedIds.remove(tag.id);
        _selected.removeWhere((t) => t.id == tag.id);
      } else {
        if (!widget.multipleSelection) {
          _selectedIds.clear();
          _selected.clear();
        }
        if (widget.maxSelection != null &&
            _selected.length >= widget.maxSelection!) {
          return;
        }
        _selectedIds.add(tag.id);
        _selected.add(tag);
      }
    });
  }

  bool get _atLimit =>
      widget.maxSelection != null && _selected.length >= widget.maxSelection!;

  Future<void> _addNewTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _saving = true;
    });
    try {
      final created = await _tagRepository.add(name);
      if (!mounted) return;
      setState(() {
        _newTagController.clear();
        final exists = _available.any((t) => t.id == created.id);
        if (!exists) {
          _available = [..._available, created]
            ..sort((a, b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        }
        if (!widget.multipleSelection) {
          _selectedIds.clear();
          _selected.clear();
        }
        if (!_atLimit) {
          _selectedIds.add(created.id);
          _selected.add(created);
        }
      });
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

  Future<void> _deleteTag(TagModel tag) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.delete),
        content: Text(localizations.areYouSureDelete(tag.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _tagRepository.delete(tag);
      if (!mounted) return;
      setState(() {
        _available.removeWhere((t) => t.id == tag.id);
        _selectedIds.remove(tag.id);
        _selected.removeWhere((t) => t.id == tag.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _onAccept() {
    widget.onSelectedTagsChanged(_selected);
    Navigator.of(context).pop(_selected);
  }

  void _onClear() {
    setState(() {
      _selected.clear();
      _selectedIds.clear();
    });
    widget.onSelectedTagsChanged([]);
    Navigator.of(context).pop(<TagModel>[]);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.multipleSelection
          ? localizations.selectTags
          : localizations.selectTag),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.maxSelection != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  localizations.maxTagsReached(widget.maxSelection!,
                      _selected.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: InputDecoration(
                      labelText: localizations.createNewTag,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addNewTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _saving ? null : _addNewTag,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  tooltip: localizations.add,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _available.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        localizations.noTagsAvailable,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _available.length,
                      itemBuilder: (context, index) {
                        final tag = _available[index];
                        final selected = _isSelected(tag);
                        final disabled = !selected && _atLimit;
                        return CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(tag.name),
                          value: selected,
                          onChanged: disabled
                              ? null
                              : (value) {
                                  if (value != null) {
                                    _toggle(tag);
                                  }
                                },
                          secondary: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.redAccent,
                            tooltip: localizations.delete,
                            onPressed: () => _deleteTag(tag),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onClear,
          child: Text(localizations.clear),
        ),
        TextButton(
          onPressed: _onAccept,
          child: Text(localizations.ok),
        ),
      ],
    );
  }
}
