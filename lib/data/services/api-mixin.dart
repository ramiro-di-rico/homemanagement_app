import 'package:http/http.dart' as http;
import 'package:http/http.dart';

mixin HttpApiServiceMixin {
  Uri backendEndpoint =
      Uri.https('www.ramiro-di-rico.dev', 'homemanagementapi/api/');

  Uri createUri(String api, {Map<String, dynamic>? queryParameters}) =>
      backendEndpoint.resolve(api).replace(queryParameters: queryParameters);

  Future<Response> httpGet(Uri uri, String token) =>
      http.get(uri, headers: createAuthHeader(token));
      
  Future<Response> httpPut(Uri uri, String token, dynamic body) =>
      http.put(uri, headers: createAuthHeader(token), body: body);

  Map<String, String> createAuthHeader(String token) {
    return {'Authorization': 'Bearer $token'};
  }
}
