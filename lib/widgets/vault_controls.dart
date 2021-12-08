import 'package:flutter/material.dart';
import 'package:projectapp/helper/helper.dart';


class VaultControlsDialog {
  static showVaultControlsDialog(
      context,
      _deviceState,
      testLEDONFieldController,
      testLEDOFFFieldController,
      _connected,
      _scaffoldKey,
      _sendTextMessageToBluetooth,
      dataIn,
      temp
      ) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
          backgroundColor: Color.fromRGBO(227, 227, 227, 1),
          insetPadding: EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Vault",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: new BorderSide(
                      color: Colors.blueAccent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  elevation: _deviceState == 0 ? 4 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            if (_connected) {
                               _sendTextMessageToBluetooth("l");
                            } else {
                              BluetoothHelper.show(
                                  _scaffoldKey, "please connect to a device");
                            }
                          },
                          child: Text(
                            "Lock",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            print(_connected);
                            if (_connected) {
                              _sendTextMessageToBluetooth("u");
                              
                            } else {
                              BluetoothHelper.show(
                                  _scaffoldKey, "please connect to a device");
                            }
                          },
                          child: Text("Unlock",
                              style: TextStyle(color: Colors.greenAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Alarm",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: new BorderSide(
                      color: Colors.blueAccent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  elevation: _deviceState == 0 ? 4 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            if (_connected) {
                               _sendTextMessageToBluetooth("A");
                            } else {
                              BluetoothHelper.show(
                                  _scaffoldKey, "please connect to a device");
                            }
                          },
                          child: Text(
                            "Enable",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            print(_connected);
                            if (_connected) {
                              _sendTextMessageToBluetooth("a");
                              
                            } else {
                              BluetoothHelper.show(
                                  _scaffoldKey, "please connect to a device");
                            }
                          },
                          child: Text(
                            "Disable",
                              style: TextStyle(color: Colors.greenAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
            ],
          )),
    );
  }
}
