import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'package:projectapp/helper/helper.dart';
import 'package:projectapp/widgets/app_bar_actions.dart';
import 'package:projectapp/widgets/get_device_items.dart';
import 'package:projectapp/widgets/vault_controls.dart';
import 'package:projectapp/widgets/send_serial_dialog.dart';
import 'package:projectapp/widgets/settings_section.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  final textFieldController = TextEditingController();

  final testLEDONFieldController = TextEditingController();
  final testLEDOFFFieldController = TextEditingController();

  final upFieldController = TextEditingController();
  final downFieldController = TextEditingController();
  final rightFieldController = TextEditingController();
  final leftFieldController = TextEditingController();

  bool checkIfPressing = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool _access = false;
  bool _correctMotion = false;
  String lockPic = 'assets/images/lockg.png';
  String dataIn = "";
  String temp ="0";
  
  Color vaultColor = Colors.grey;

  Color _pin1 = Colors.grey;
  Color _pin2 = Colors.grey;
  Color _pin3 = Colors.grey;
  Color _pin4 = Colors.grey; 

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    BluetoothHelper.enableBluetooth(_bluetoothState, getPairedDevices);

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Vault App"),
          backgroundColor: Colors.blueAccent,
          actions: <Widget>[
            AppBarActions.appBarActions(getPairedDevices, _scaffoldKey),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "PAIRED DEVICES",
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 100,
                      child: DropdownButton(
                        isExpanded: true,
                        items: GetDeviceItems.getDeviceItems(_devicesList),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty ? _device : null,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isButtonUnavailable
                          ? null
                          : _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect'),
                    ),
                  ],

                ),
              ),
             
              SizedBox(
                height: 10,
              ),
              Divider(),
              
              ElevatedButton(
                child: Text("Enable MPS"),
                
                onPressed: () {
                  setState(() {
                    _access =true;
                  });
                  showDialog(
                        context: context, 
                        builder: (BuildContext context){
                          return AlertDialog( 
                        title: Text(""),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text("Begin motion password"),
                          ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Ok"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                        }

                        );
                  connection.input.listen((Uint8List data) {
                    print(ascii.decode(data));
                    
                    
                    if(ascii.decode(data).contains("1") && _correctMotion == false)
                    {
                      setState(() {
                        _pin1= Colors.green;
                      });
                    }
                    if(ascii.decode(data).contains("2") && _correctMotion == false)
                    {
                      setState(() {
                        _pin2= Colors.green;
                      });
                    }
                    if(ascii.decode(data).contains("3") && _correctMotion == false)
                    {
                      setState(() {
                        _pin3= Colors.green;
                      });
                    }
                    if(ascii.decode(data).contains("X") && _correctMotion == false)
                    {
                      setState(() {
                        _pin1= Colors.grey;
                        _pin2 = Colors.grey;
                        _pin3= Colors.grey;
                        _pin4 = Colors.grey;
                      });
                    }
                    if(ascii.decode(data).contains("T"))
                    {
                      setState(() {
                        
                        _access = true;
                        lockPic = 'assets/images/lock.png';
                        vaultColor = Colors.blueAccent;
                        _pin4 = Colors.green;
                        _correctMotion = true;
                      });
                      showDialog(
                        context: context, 
                        builder: (BuildContext context){
                          return AlertDialog( 
                        title: const Text(""),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text("Before entering vault controls"),
                              Text("Switch to Device 2"),
                          ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Ok"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                        }

                        );

                      
                    }
                   });
                  
                },
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    color: _pin1,
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    color: _pin2,
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    color: _pin3,
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    color: _pin4,
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Vault",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: vaultColor),
                ),
              ),
                IconButton(
                iconSize: 100,
                icon: Image.asset(
                  lockPic
                ),
                onPressed: () {
                  if(_access == true){
                    _access = false;
                    setState(() {
                      _correctMotion = false;
                      lockPic = 'assets/images/lockg.png';
                      vaultColor = Colors.grey;
                      _pin1= Colors.grey;
                      _pin2 = Colors.grey;
                      _pin3= Colors.grey;
                      _pin4 = Colors.grey;
                      });
                    return VaultControlsDialog.showVaultControlsDialog(
                      context,
                      _deviceState,
                      testLEDONFieldController,
                      testLEDOFFFieldController,
                      _connected,
                      _scaffoldKey,
                      _sendTextMessageToBluetooth,
                      dataIn,
                      temp
                      );

                  }
                  else{
                    return;
                  }
                  
                },
              ),
              TextButton(
                onPressed :()
              {
                if (_connected) {
                  _sendTextMessageToBluetooth("t");
                              
                } else {
                  BluetoothHelper.show(
                  _scaffoldKey, "please connect to a device");
                }
              },
               child: Text("Temperature:",
               style: TextStyle(fontSize: 17),
               )),
              TextButton(
                onPressed :()
              {
              },
               child: Text(temp + "°F",
               style: TextStyle(fontSize: 17, color: Colors.black),
               )),
                ],
              ),
              
              
              Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Sending To Bluetooth",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                  iconSize: 100,
                  icon: Image.asset(
                    'assets/images/chat.png',
                  ),
                  onPressed: () {
                    _access = true;
                    return SendSerialDialog.showSerialDialog(
                        context,
                        textFieldController,
                        _connected,
                        _scaffoldKey,
                        _sendTextMessageToBluetooth);
                  },
                ),
              ),
              SizedBox(height: 20),
              SettingSection.settingSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      BluetoothHelper.show(_scaffoldKey, 'No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        BluetoothHelper.show(_scaffoldKey, 'Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _deviceState = 0;
    });

    await connection.close();
    BluetoothHelper.show(_scaffoldKey, 'Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _sendTextMessageToBluetooth(String message) async {
    
    connection.output.add(utf8.encode(message + "\r\n"));
    await connection.output.allSent;
    
    connection.input.listen(null).onData((data) {
      String d ="";
      d = d + ascii.decode(data);
      print(d);
      if(d!= "*" && d!="" && int.tryParse(d)!=null)
      {
        setState(() {
          print("TEST");
          temp = d;
        });
      }
      }
      
      );
      
   // connection.input.listen((data) { 
   // d = d + ascii.decode(data);
    
   // });
   // print(d);
 
    setState(() {
      _deviceState = -1; // device off
    });
    
  }

  
  

  // Method to show a Snackbar,
  // taking message as the text

}
