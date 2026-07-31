import 'dart:convert';

import 'package:home_management_app/data/models/transaction_projection_response.dart';
import 'package:home_management_app/data/services/authentication.service.dart';

import 'api-mixin.dart';

class TransactionProjectionService with HttpApiServiceMixin {
  AuthenticationService authenticationService;

  TransactionProjectionService({required this.authenticationService});

  Future<TransactionProjectionResponse> getTransactionProjections({
    int? accountId,
    int lookbackMonths = 6,
  }) async {
    var path =
        accountId == null ? 'account/projections' : 'account/$accountId/projections';

    var response = await httpGet(
      createUri(path, queryParameters: {
        'lookbackMonths': lookbackMonths.toString(),
      }),
      authenticationService.getUserToken(),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return TransactionProjectionResponse.fromJson(body);
    } else {
      throw Exception('Failed to fetch transaction projections.');
    }
  }
}
