import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(MyApp());
}

var logger = Logger(
  printer: PrettyPrinter(),
);
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
    case 'advertiser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.advertiser));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            child: Text("Log"),
            onPressed: () {
              logger.d('TEST LOGGING!');
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'browser');
                //DevicesListScreen(deviceType: DeviceType.browser));
                //DeviceListScreen gets the deviceType DeviceType.browser fed
                // Through this the DeviceListScreen knows what to do next, if it's a browser.
              },
              child: Container(
                color: Colors.red,
                child: Center(
                    child: Text(
                  'BROWSER',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'advertiser');
                // Opens
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                  'ADVERTISER',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  //Devices like DeviceType.browser and DeviceType.advertiser are given here
  //and made into objects.
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  //A List is made of all the devices which are found
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  //A List is made of all the devices which are connected.
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  //Some variables are declared, which later will be defined
  bool isInit = false;

  //When the Widget is created, initState is initialized as an instance of this widget.

  //BROWSER STEP: 1

  /*
  * ADVERTISER STEP: 1
  */

  //STARTUP INITIALIZING
  @override
  void initState() {
    print("Line 126");
    super.initState();
    init();
  }

  //Shutdown the the search
  @override
  void dispose() {
    print("Line 134");
    subscription.cancel();
    receivedDataSubscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.deviceType.toString().substring(11).toUpperCase()),
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              final device = widget.deviceType == DeviceType.advertiser
                  ? connectedDevices[index]
                  : devices[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () => _onTabItemListener(device),
                          child: Column(
                            children: [
                              Text(device.deviceName),
                              Text(
                                getStateName(device.state),
                                style: TextStyle(
                                    color: getStateColor(device.state)),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        )),
                        // Request connect
                        GestureDetector(
                          onTap: () => _onButtonClicked(device),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
                ),
              );
            }));
  }

  //ALSO GIVES THE STATE IF SOMETHING HAS BEEN CONNECTED, IS WAITING OR DISCONNECTED.
  String getStateName(SessionState state) {
    //BROWSER STEP: 6

    /*
    * ADVERTISER STEP: 6
    */
    print("Line 212");
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  //Says if the button connect or disconnect was pressed.
  //Maybe it changes also the text of the button, because of the setState

  //CHANGES THE STATE OF THE BUTTON CONNECTED OR DISCONNECTED, LIKE A SWITCH
  String getButtonStateName(SessionState state) {
    //BROWSER STEP: 9

    /*
    * ADVERTISER STEP: 9
    */
    print("Line 226");
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  //CHANGES THE STATE OF THE BUTTON COLOURS NOT CONNECTED, CONNECTING AND DISCONNECTED
  Color getStateColor(SessionState state) {
    //BROWSER STEP: 7

    /*
    * ADVERTISER STEP: 7
    */

    print("Line 238");
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  //CHANGES THE COLOURS OF THE BUTTON FROM RED TO GREEN, LIKE A SWITCH
  Color getButtonColor(SessionState state) {
    //BROWSER STEP: 8

    /*
    * ADVERTISER STEP: 8
    */
    print("Line 252");
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  //DEVICE SELECTION HANDLER
  _onTabItemListener(Device device) {
    //BROWSER STEP: 11 (The device was clicked on, to send a message.)

    /*
    * ADVERTISER STEP: 11 (The device was clicked on, to send a message.)
    */

    //HANDLES THE SENDING OF THE MESSAGE IF THE DEVICE IS CONNECTED
    print("Line 263");
    if (device.state == SessionState.connected) {
      //BROWSER STEP: 12
      /*
      * ADVERTISER STEP: 12
      */
      print("Line 265");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return AlertDialog(
              title: Text("Send message"),
              content: TextField(controller: myController),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Send"),
                  onPressed: () {
                    //BROWSER STEP: 13
                    /*
                    * ADVERTISER STEP: 13
                    */

                    //CALLING A HANDLER TO ACTUALLY SEND THE MESSAGE
                    nearbyService.sendMessage(
                        device.deviceId, myController.text);
                    myController.text = '';
                  },
                ),
              ],
            );
          });
    }
  }

  //CONNECT AND DISCONNECT
  int getItemCount() {
    //BROWSER STEP: 3
    //BROWSER STEP: 5
    //BROWSER STEP: 15 (Connection finished.)
    /*
    * ADVERTISER STEP: 3
    * ADVERTISER STEP: 5
    * ADVERTISER STEP: 15 (Connection finished.)
    */
    print("Line 295");
    if (widget.deviceType == DeviceType.advertiser) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  //HANDLING THE BUTTON CLICK OF CONNECT AND DISCONNECT
  _onButtonClicked(Device device) {
    //BROWSER STEP: 10 (The Advertiser has now been connected to the browser. The whole process
    //of button pressing has been documented.)
    print("Line 304");
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  //INIT IS CALLED AND THE DEVICE MODEL IS SET. (ANDROID IOS)
  void init() async {
    //BROWSER STEP: 2

    /*
    * ADVERTISER STEP: 2
    */
    print("Line 321");
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model!;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel!;
    }
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            if (widget.deviceType == DeviceType.browser) {
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startBrowsingForPeers();
            } else {
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startAdvertisingPeer();
              await nearbyService.startBrowsingForPeers();
            }
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      });

      //CHECKS FOR DEVICES AND SHOWS YOU THEIR STATE
      setState(() {
        //BROWSER STEP: 4 (I wait for another device and search for it.)
        //BROWSER STEP: 14 (The Connection is ended.)

        /*
        * ADVERTISER STEP: 4 (The Browser connects to this Advertiser after being found)
        * ADVERTISER STEP: 14 (The Connection is ended.)
        */
        print("Line 368");
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });

    //Message received
    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
      print("TheMessage: ${jsonEncode(data)}");
      showToast(jsonEncode(data),
          context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    });
  }
}
