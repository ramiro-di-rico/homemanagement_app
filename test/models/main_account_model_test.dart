import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/models/main_account.dart';

void main() {
  group('MainAccountModel JSON compatibility', () {
    test('toJson includes both id and MainAccountId', () {
      final model = MainAccountModel(12, 'Savings', 3, 0, false);

      final json = model.toJson();

      expect(json['id'], 12);
      expect(json['MainAccountId'], 12);
    });

    test('fromJson can read MainAccountId when id is missing', () {
      final model = MainAccountModel.fromJson({
        'MainAccountId': 27,
        'name': 'Main',
        'userId': 7,
        'childAccountCount': 0,
        'isHidden': true,
      });

      expect(model.id, 27);
      expect(model.name, 'Main');
      expect(model.isHidden, true);
    });
  });
}

