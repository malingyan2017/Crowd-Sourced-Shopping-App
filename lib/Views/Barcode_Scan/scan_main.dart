import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Views/Barcode_Scan/scan_result.dart';
import 'package:shopping_app/Views/Barcode_Scan/tags_form.dart';
import 'package:shopping_app/Views/Barcode_Scan/update_form.dart';
import 'package:shopping_app/Models/store.dart';

//source:  https://pub.dev/packages/flutter_barcode_scanner/example
//https://www.youtube.com/watch?v=4QpzUDc-c7A&list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC&index=21&ab_channel=TheNetNinja

class BarcodeScan extends StatefulWidget {
  @override
  _BarcodeScanState createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScan> {
  String scanResult = '';

  // scan barcode function.
  Future<void> scanBarcode() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      scanResult = barcodeScanRes;
    });
  }

  String maskResult(String barcode) {
    if (barcode == '-1') {
      return 'You cancel the camera';
    } else {
      return barcode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: user.uid).getCurrentUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          Map<String, dynamic> data = snapshot.data.data();
          Store preferredStore;
          if (data['preferredLocation'] != null) {
            preferredStore = Store.storeFromMap(data['preferredLocation']);
          }

          return Column(
            children: <Widget>[
              SizedBox(height: 20),
              FlatButton(
                onPressed: () {
                  if (preferredStore == null) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Please Choose Your Location First',
                        style: TextStyle(color: Colors.red),
                      ),
                    ));
                  } else {
                    scanBarcode();
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 60,
                    ),
                    Text('Scan to Update Item'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(maskResult(scanResult)),
              Expanded(
                child: ScanResult(
                  scan_result: scanResult,
                  preferredStore: preferredStore,
                ),
              ),
            ],
          );
        });
  }
}
