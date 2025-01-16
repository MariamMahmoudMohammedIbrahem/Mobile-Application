import 'package:flutter/cupertino.dart';

import 'localization_service.dart';

enum TKeys{
  accessLocation,
  accessCamera,
  accessBluetooth,
  arabic,
  english,
  scan,
  scanning,
  device,
  notConnected,
  hint,
  first,
  electricity,
  water,
  close,
  failed,
  qr,
  change,
  welcome,
  name,
  currentTarrif,
  totalReadings,
  valveStatus,
  balance,
  consumption,
  recharge,
  recharged,
  history,
  timeOut,
  upToDate,
  // logout,
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december,
  update,
  updated,
  charge,
  request,
  choose,
  meter,
  tariff,
  balanceStation,
  submit,
  connect,
  connecting,
  disconnect,
  disconnecting,
  selectDevice,
  welcomeMaster,
  id,
  uploadData,
  dataSent,
  meterData,
  tariffVersion,
  tariffPrice,
  chargingData,

}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context)=> LocalizationService.of(context)?.translate(_string)??'';
}