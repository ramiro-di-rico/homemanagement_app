import 'package:flutter/material.dart';

import '../../models/tag.dart';
import '../endpoints/tag.service.dart';

class TagRepository extends ChangeNotifier {
  TagService tagService;
  final List<TagModel> tags = [];

  TagRepository(this.tagService);

  Future load() async {
    tags.clear();
    final result = await tagService.fetchAll();
    tags.addAll(result);
    _sort();
    notifyListeners();
  }

  Future<TagModel> add(String name) async {
    final trimmed = name.trim();
    final existing = _findByName(trimmed);
    if (existing != null) {
      return existing;
    }
    final created = await tagService.create(trimmed);
    tags.add(created);
    _sort();
    notifyListeners();
    return created;
  }

  Future<TagModel?> findOrCreate(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final existing = _findByName(trimmed);
    if (existing != null) {
      return existing;
    }
    return add(trimmed);
  }

  Future update(TagModel tag) async {
    await tagService.update(tag);
    final index = tags.indexWhere((element) => element.id == tag.id);
    if (index >= 0) {
      tags[index] = tag;
    }
    _sort();
    notifyListeners();
  }

  Future delete(TagModel tag) async {
    await tagService.delete(tag.id);
    tags.removeWhere((element) => element.id == tag.id);
    notifyListeners();
  }

  TagModel? _findByName(String name) {
    final lower = name.toLowerCase();
    for (final tag in tags) {
      if (tag.name.toLowerCase() == lower) {
        return tag;
      }
    }
    return null;
  }

  void _sort() {
    tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
