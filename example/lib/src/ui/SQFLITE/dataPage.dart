import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_interaction_tab.dart';

class StoreData extends StatefulWidget {
  const StoreData({required this.device,
    Key? key,
  }) : super(key: key);
  final DiscoveredDevice device;
  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  SqlDb sqlDb = SqlDb();
  Future<List<Map>> readData() async {
    final response  = await sqlDb.readData("SELECT * FROM Electricity");
    return response;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          sqlDb.mydeleteDatabase();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        items: const [
          Icon(
            Icons.electric_bolt_outlined,
            size: 30,
          ),
          Icon(Icons.add_circle_outline, size: 30),
          Icon(Icons.water_drop_outlined, size: 30),
        ],
        color: Colors.deepPurple.shade50,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
            if (index == 0) {}
            else if (index == 1) {
              Navigator.of(context).pushAndRemoveUntil<void>(
                MaterialPageRoute<void>(builder: (context) => DeviceInteractionTab(
                  device: dataStored, characteristic: QualifiedCharacteristic(
                    characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                    serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                    //device id get from register page when connected
                    deviceId: dataStored.id),
                  )
                ),
                    (route) => false,
              );
            }
            else if (index == 2) {
            }
        },
      ),
      body: ListView(
        children: [
          FutureBuilder(
              future: readData(),
              builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                if(snapshot.hasData){
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context,i)=> Card(
                          child: ListTile(
                            title: Text("ClientID: ${snapshot.data![i]['clientId']}"),
                            subtitle: Column(
                              children: [
                                Text("Device Name: ${snapshot.data![i]['title']}"),
                                Text("Balance: ${snapshot.data![i]['totalCredit']}"),
                              ],
                            ),
                            trailing: Text("${snapshot.data![i]['time']}"),
                          ),
                        )
                  );
                }
                return const Center(child: CircularProgressIndicator(),);
              }
          ),
        ],
      ),
    );
}
