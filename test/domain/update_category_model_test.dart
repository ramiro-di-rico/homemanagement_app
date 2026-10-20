import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/domain/models/category.dart';

void main() {
  test('the update body names the category by `id`, which is what the server binds', () {
    final body = UpdateCategoryModel.fromCategoryModel(
        CategoryModel(42, 7, 'Rent', 'home', true, false, '#112233')).toJson();

    expect(body['id'], 42);
    expect(body['name'], 'Rent');
    expect(body['icon'], 'home');
    expect(body['measurable'], true);
    expect(body['isActive'], false);
    expect(body['color'], '#112233');
  });
}
