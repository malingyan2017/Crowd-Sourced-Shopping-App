import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Views/Barcode_Scan/tags_form.dart';
import 'package:shopping_app/Views/Barcode_Scan/update_form.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    void _showUpdateForm(String storeId, String itemId) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: UpdateForm(
                storeId: storeId,
                itemId: itemId,
              ),
            );
          });
    }

    void _showTagsForm() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: TagsForm(
                barcode: scanResult,
              ),
            );
          });
    }

    return Column(
      children: [
        RaisedButton(
          onPressed: () => scanBarcode(),
          child: Text("Start barcode scan"),
        ),
        Text(scanResult),
        Flexible(
          child: StreamBuilder<DocumentSnapshot>(
              stream: DatabaseService(uid: user.uid).getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                var data = snapshot.data;
                String storeId = data['preferredLocation.id'];
                String storeName = data['preferredLocation.name'];
                String storeZipcode = data['preferredLocation.zipCode'];

                return scanResult == ''
                    ? Text(
                        'no item is scanned yet, you are at $storeName with zipcode $storeZipcode')
                    : StreamBuilder<QuerySnapshot>(
                        stream: DatabaseService()
                            .getStoreItemStream(storeId, scanResult),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }
                          return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot data =
                                    snapshot.data.docs[index];
                                var userUpdateId = data['userId'];
                                var itemId = data.id;

                                return StreamBuilder<DocumentSnapshot>(
                                    stream: DatabaseService(uid: userUpdateId)
                                        .getUserStream(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Something went wrong');
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Loading");
                                      }
                                      var data1 = snapshot.data;
                                      String userUpdateName = data1['username'];
                                      return Card(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      data['pictureUrl']),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('name: ${data['name']}'),
                                                Text('price: ${data['price']}'),
                                                Text(
                                                    'update by: $userUpdateName'),
                                                Text(
                                                    'updated: ${data['dateUpdated'].toDate().toString()}'),
                                                Text(
                                                    'on sale: ${data['onSale']}')
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RaisedButton(
                                                  child: Text('update item'),
                                                  onPressed: () =>
                                                      _showUpdateForm(
                                                          storeId, itemId),
                                                ),
                                                RaisedButton(
                                                  child: Text('add tags'),
                                                  onPressed: () =>
                                                      _showTagsForm(),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              });
                        });
              }),
        ),
      ],
    );
  }
}
