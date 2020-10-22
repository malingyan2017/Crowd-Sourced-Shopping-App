import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    return Column(
      children: [
        Container(
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
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
              //if no search, show 3 items, if there is search, show specific items found
              stream: (searchName != '' && searchName != null)
                  ? specificItems.snapshots()
                  : items.limit(3).snapshots(),
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data = snapshot.data.docs[index];
                          return Card(
                              child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(data['pictureUrl']))),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
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
                                    items: <int>[1, 2, 3, 4, 5, 6, 7]
                                        .map<DropdownMenuItem<int>>((quantity) {
                                      return DropdownMenuItem<int>(
                                        child: Text(quantity.toString()),
                                        value: quantity,
                                      );
                                    }).toList(),
                                  ),
                                  RaisedButton(
                                      child: Text('add to cart'),
                                      onPressed: () {}),
                                ],
                              )
                            ],
                          ));
                        },
                      );
              }),
        ),
      ],
    );
  }
}
