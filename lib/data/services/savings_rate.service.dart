import 'dart:convert';

import 'package:home_management_app/data/models/savings_rate_response.dart';
import 'package:home_management_app/data/services/authentication.service.dart';

import 'api-mixin.dart';

class SavingsRateService with HttpApiServiceMixin {
  AuthenticationService authenticationService;

  SavingsRateService({required this.authenticationService});

  Future<SavingsRateResponse> getSavingsRate({
    int? accountId,
    int lookbackMonths = 6,
  }) async {
    var path = accountId == null
        ? 'account/savings-rate'
        : 'account/$accountId/savings-rate';

    var response = await httpGet(
      createUri(
        path,
        queryParameters: {'lookbackMonths': lookbackMonths.toString()},
      ),
      authenticationService.getUserToken(),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return SavingsRateResponse.fromJson(body);
    } else {
      throw Exception('Failed to fetch savings rate.');
    }
  }
}
