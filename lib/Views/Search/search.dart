import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Search/dropDownButton.dart';

//https://morioh.com/p/3522d01c11ef

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchName;

  @override
  Widget build(BuildContext context) {
    //items to show when there is no searchName found
    CollectionReference items = FirebaseFirestore.instance.collection('item');

    //items to show when there is items matched to searchName
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
                                    image: NetworkImage(data['pictureUrl']),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('name: ${data['name']}'),
                                  MyDropDownButton(),
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
