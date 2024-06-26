import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/localization_service.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_status_monitor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/permissions/bluetooth_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/camera_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/location_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/permission_provider.dart';
import 'package:flutter_reactive_ble_example/src/ui/ble_status_screen.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_list.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'src/ble/ble_logger.dart';

Color _themeColor = Colors.grey.shade200;

Future<void> main() async {
  final localizationController = Get.put(LocalizationController());
  locationWhenInUse = await Permission.locationWhenInUse.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  statusCamera = await Permission.camera.status;
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: _ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionProvider(),
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: GetBuilder<LocalizationController>(
          init: localizationController,
          builder: (LocalizationController controller) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MeterSense',
                color: Colors.grey,
                theme: ThemeData(
                  popupMenuTheme:  PopupMenuThemeData(
                    color: Colors.grey.shade100, // Default background color
                  ),
                  primaryColor: Colors.grey,
                  primarySwatch: Colors.grey,
                  scaffoldBackgroundColor: Colors.white,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey[600],
                      shape: const StadiumBorder(),
                      disabledForegroundColor: Colors.grey.withOpacity(0.38),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                    ),
                  ),
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                locale: controller.currentLanguage != ''
                    ? Locale(controller.currentLanguage, '')
                    : null,
                localeResolutionCallback:
                    LocalizationService.localeResolutionCallBack,
                supportedLocales: LocalizationService.supportedLocales,
                localizationsDelegates:
                    LocalizationService.localizationsDelegate,
                // localizationsDelegates: const [
                //   GlobalMaterialLocalizations.delegate,
                //   GlobalWidgetsLocalizations.delegate,
                // ],
                // supportedLocales: const [
                //   Locale('en', ''), // English
                //   Locale('ar', ''), // Arabic
                //   // Add more locales as needed
                // ],
                home: const HomeScreen(),
              )),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleStatus?, PermissionProvider>(
        builder: (_, status, permission, __) {
          if (status == BleStatus.ready &&
              permission.cameraStatus.isGranted &&
              permission.whenInUseLocation.isGranted &&
              permission.bluetoothStatus.isGranted) {
            return const MyApp();
          } else if (permission.bluetoothStatus.isDenied) {
            permission.requestBluetoothPermission();
            return const BluetoothPermission();
          } else if (permission.whenInUseLocation.isDenied) {
            permission.requestLocationWhenInUse();
            return const LocationPermission();
          } else if (permission.cameraStatus.isDenied) {
            permission.requestCameraPermission();
            return const CameraPermission();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
