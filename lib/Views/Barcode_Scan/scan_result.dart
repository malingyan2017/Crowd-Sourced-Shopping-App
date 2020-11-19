import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Views/Barcode_Scan/empty_scan.dart';

import 'package:shopping_app/Views/Barcode_Scan/tags_form.dart';
import 'package:shopping_app/Views/Barcode_Scan/update_form.dart';

import 'package:shopping_app/Models/store.dart';
import 'package:intl/intl.dart';

class ScanResult extends StatefulWidget {
  final String scan_result;
  ScanResult({this.scan_result});
  @override
  _ScanResultState createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  //function for update item button, return a bottom sheet
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

  //function for add tag button, return a bottom sheet
  void _showTagsForm(String itemId, dynamic tags) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: TagsForm(
              itemId: itemId,
              tags: tags,
            ),
          );
        });
  }

  //mask the dropdown menu for user friendly purpose.
  String yesOrNo(bool choice) {
    if (choice) {
      return 'Yes';
    } else {
      return 'No';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    //final items = Provider.of<QuerySnapshot>(context);

    return Flexible(
      //get current user stream to get prefered store info
      child: StreamBuilder<DocumentSnapshot>(
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

            //String storeId;

            return widget.scan_result == ''
                ? preferredStore == null
                    ? Text(
                        'No store was chosen, click  on upper left icon to set')
                    : EmptyScan(
                        storeName: preferredStore.name,
                        storeZipcode: preferredStore.zipCode,
                      )
                : StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getStoreItemStream(
                        preferredStore.id, widget.scan_result),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('Loading');
                      }
                      if (snapshot.data.docs.isEmpty) {
                        return Text('No item found for this barcode');
                      }
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            //stream to get storeItem's info
                            DocumentSnapshot data = snapshot.data.docs[index];
                            //stream to get storeItem's update user info
                            var userUpdateId = data['userId'];
                            var itemId = data.id;
                            Timestamp timestamp = data['dateUpdated'];
                            DateTime myDateTime =
                                DateTime.parse(timestamp.toDate().toString());
                            String formattedDateTime =
                                DateFormat('MM-dd-yyyy').format(myDateTime);

                            String salesInfo =
                                'On Sales : ${yesOrNo(data['onSale'])}';

                            return StreamBuilder<DocumentSnapshot>(
                                stream: DatabaseService(uid: userUpdateId)
                                    .getCurrentUserStream(),
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
                                  int userUpdatePoints = data1['rankPoints'];
                                  String userUpdateRank =
                                      DatabaseService(uid: user.uid)
                                          .getUserRank(userUpdatePoints);
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Product Details:',
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 70,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${data['name']}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '\$'
                                                        '${data['price'].toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.green[800],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      Text(
                                                          'Update By: $userUpdateName'),
                                                      Text(
                                                          'Updated On: $formattedDateTime'),
                                                      Text(salesInfo),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: RaisedButton(
                                                //color: Theme.of(context).accentColor,
                                                child: Text('Update Price'),
                                                onPressed: () =>
                                                    _showUpdateForm(
                                                        preferredStore.id,
                                                        itemId),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StreamBuilder(
                                          stream: DatabaseService(uid: user.uid)
                                              .getItemStream(
                                                  widget.scan_result),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  'Something went wrong');
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text("Loading");
                                            }
                                            DocumentSnapshot data =
                                                snapshot.data.docs[index];
                                            var tags = data['tags'];
                                            var itemId = data.id;
                                            return Card(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Popular Item Tags:',
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 80,
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: tags.length,
                                                        itemBuilder:
                                                            (BuildContext ctxt,
                                                                int index) {
                                                          return Text(
                                                              tags[index]);
                                                        }),
                                                  ),
                                                  SizedBox(
                                                    width: 120,
                                                    child: RaisedButton(
                                                      //color: Theme.of(context).accentColor,
                                                      child: Text('Add Tags'),
                                                      onPressed: () =>
                                                          _showTagsForm(
                                                              itemId, tags),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ],
                                  );
                                });
                          });
                    });
          }),
    );
  }
}
