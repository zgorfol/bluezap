import 'package:bluezap/bluetoothProvider.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

//Service locator description
void locator_init() {
  locator.registerLazySingleton<BluetoothProvider>(() => BluetoothProvider());
}
