import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/controllers/pet_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PetController applies feed action correctly', () async {
    final controller = PetController();
    await controller.init();

    final initialHunger = controller.pet.hunger;
    await controller.feed();

    expect(controller.pet.hunger, lessThan(initialHunger));
    expect(controller.pet.coins, greaterThanOrEqualTo(2));
    expect(controller.pet.experience, greaterThanOrEqualTo(8));
  });

  test('PetController can reset progress for daily goals', () async {
    final controller = PetController();
    await controller.init();
    controller.dailyGoals[0].progress = controller.dailyGoals[0].target;

    await controller.resetProgress();

    expect(controller.dailyGoals[0].progress, 0);
  });
}
