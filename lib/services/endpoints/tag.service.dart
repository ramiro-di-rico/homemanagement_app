import 'dart:convert';

import '../../models/tag.dart';
import '../infra/error_notifier_service.dart';
import '../security/authentication.service.dart';
import 'api.service.factory.dart';

class TagService {
  AuthenticationService authenticationService;
  late ApiServiceFactory apiServiceFactory;
  NotifierService notifierService;
  final String apiName = 'tags';

  TagService(
      {required this.authenticationService,
      required this.apiServiceFactory,
      required this.notifierService}) {
    this.apiServiceFactory =
        ApiServiceFactory(authenticationService: this.authenticationService);
  }

  Future<List<TagModel>> fetchAll() async {
    final data = await apiServiceFactory.apiGet(apiName) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? const [];
    return items
        .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TagModel> create(String name) async {
    final body = json.encode(CreateTagRequest(name).toJson());
    final result = await apiServiceFactory.postWithReturn(apiName, body);
    notifierService.notify('Tag "$name" created');
    return TagModel.fromJson(result as Map<String, dynamic>);
  }

  Future<TagModel> update(TagModel tag) async {
    final body = json.encode(UpdateTagRequest(tag.name).toJson());
    final result = await apiServiceFactory.apiPut(
        '$apiName/${tag.id}', body);
    notifierService.notify('Tag "${tag.name}" updated');
    if (result is Map<String, dynamic>) {
      return TagModel.fromJson(result);
    }
    return tag;
  }

  Future<void> delete(int id) async {
    await apiServiceFactory.apiDelete(apiName, id.toString());
    notifierService.notify('Tag deleted');
  }
}
