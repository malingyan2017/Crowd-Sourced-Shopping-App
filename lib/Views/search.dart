import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//borrowed search code and idea from https://morioh.com/p/3522d01c11ef

//drop down menu borrowed from https://api.flutter.dev/flutter/material/DropdownButton-class.html

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchName;

  //variable for the drop down menu
  int quantity;

  @override
  Widget build(BuildContext context) {
    CollectionReference items = FirebaseFirestore.instance.collection('item');
    Query specificItems = FirebaseFirestore.instance
        .collection('item')
        .where('tags', arrayContains: searchName);

    return Scaffold(
        appBar: AppBar(
          title: Card(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'enter your search',
              ),
              onChanged: (val) {
                setState(() {
                  searchName = val;
                });
              },
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          //if no search, show 10 items, if search, show specific items found
          stream: (searchName != '' && searchName != null)
              ? specificItems.snapshots()
              : items.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            print(snapshot);
            print(searchName);

            if (snapshot == null) {
              return Text('Nothing matched here');
            }

            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot data = snapshot.data.docs[index];

                  return Column(
                    children: [
                      Card(
                          child: Row(
                        children: <Widget>[
                          Image.network(
                            data['pictureUrl'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('name: ${data['name']}'),
                              DropdownButton<int>(
                                hint: Text('quantity'),
                                value: quantity,
                                onChanged: (value) {
                                  setState(() {
                                    quantity = value;
                                  });
                                },
                                items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                    .map<DropdownMenuItem<int>>((quantity) {
                                  return DropdownMenuItem<int>(
                                    child: Text(quantity.toString()),
                                    value: quantity,
                                  );
                                }).toList(),
                              ),
                              RaisedButton(
                                child: Text('add to cart'),
                                onPressed: () {},
                              )
                            ],
                          ),
                        ],
                      )),
                    ],
                  );
                });
          },
        ));
  }
}
