import 'package:get_it/get_it.dart';
import 'helper/helper.dart';

GetIt serviceLocator = GetIt.instance;

Future<void> initServiceLocator() async {

  serviceLocator
      .registerSingleton<FireBaseCoreHelper>(FireBaseCoreHelper());

  // initialize firebase core
  await Future.wait([
    serviceLocator<FireBaseCoreHelper>().initialize(),
  ]);

  serviceLocator
      .registerSingleton<FirebaseAuthHelper>(FirebaseAuthHelper());

  serviceLocator
      .registerSingleton<CloudFirestoreHelper>(CloudFirestoreHelper());
}