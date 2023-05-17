import 'package:http/http.dart' as http;
import 'package:http/http.dart';

mixin HttpApiServiceMixin {
  Uri backendEndpoint =
      Uri.https('ramiro-di-rico.dev', 'homemanagementapi/api/');

  Uri createUri(String api, Map<String, dynamic>? queryParameters) =>
      backendEndpoint.resolve(api).replace(queryParameters: queryParameters);

  Future<Response> httpGet(Uri uri, String token) =>
      http.get(uri, headers: createAuthHeader(token));

  Map<String, String> createAuthHeader(String token) {
    return {'Authorization': 'Bearer $token'};
  }
}
