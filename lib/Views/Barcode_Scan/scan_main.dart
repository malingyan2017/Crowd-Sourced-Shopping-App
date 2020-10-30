import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//source: https://pub.dev/packages/flutter_barcode_scanner/example

class BarcodeScan extends StatefulWidget {
  @override
  _BarcodeScanState createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScan> {
  String scanResult = 'unknown barcode';

  String myStoreId = '';

  String mystore = '';

  // get myStoreId function
  void myStoreIdInfo() {
    var user = FirebaseAuth.instance.currentUser.uid;
    var userquery = FirebaseFirestore.instance.collection('users').doc(user);
    userquery.get().then((value) {
      if (value.data().length > 0) {
        print(myStoreId);
        setState(() {
          myStoreId = value.data()['preferredLocation'];
        });
      } else {
        print('id doesn not exist');
      }
    });
  }

  /*
  void myStore() {
    var user = FirebaseAuth.instance.currentUser.uid;
    var userquery =
        FirebaseFirestore.instance.collection('stores').doc(myStoreId);

    userquery.get().then((value) {
      setState(() {
        mystore = value.data()['name'];
      });
    });
  }
*/
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    myStoreIdInfo();
    print(myStoreId);
    DocumentReference stores =
        FirebaseFirestore.instance.collection('stores').doc(myStoreId);

    if (myStoreId == null) {
      return Text(
          'please go to the update user file side drawer and choose one');
    }

    //myStore();
    //var myStore = DatabaseService(uid: user.uid).getStoreSnapshot(myStoreId);
    //print(myStore);
    //print(myStore.get(name));

    return Column(
      children: [
        RaisedButton(
          onPressed: () => scanBarcode(),
          child: Text("Start barcode scan"),
        ),
        Text(scanResult),
        StreamBuilder<Object>(
            stream: stores.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return ListTile(
                title: Text(snapshot.data),
              );
            }),
        /*
        FutureBuilder(
            future: DatabaseService(uid: user.uid).getStoreSnapshot(myStoreId),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(snapshot.data["name"]),
                      );
                    });
              } else if (snapshot.connectionState == ConnectionState.none) {
                return Text("No data");
              } else {
                return CircularProgressIndicator();
              }
            })
            */

        /*
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stores')
                .doc(myStoreId)
                .collection('storeItems')
                .where('barCode', isEqualTo: scanResult)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Text('${snapshot.data.docs[0]['name']}'),
                        Text(scanResult),
                        //Text(mystore['name']),
                      ],
                    );
            }),
            */
      ],
    );
  }
}
