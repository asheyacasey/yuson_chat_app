import 'package:yuson_chat_app/src/controller/auth_controller.dart';
import 'package:yuson_chat_app/src/controller/navigation/navigation_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocators() {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<AuthController>(AuthController());
}