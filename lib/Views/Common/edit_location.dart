import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Util/measure.dart';

class UpdateLocation extends StatelessWidget {
  static const String routeName = '/editLocation';
  static const String appBarTitle = 'Edit Location';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Store preferredStore;

  UpdateLocation({Key key, this.preferredStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: db.getStoreListQuery(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          else if (snapshot.connectionState == ConnectionState.done) {
            List<Store> storeList = db.queryToStoreList(snapshot.data.docs);

            return _StoreDropDown(
              storeList: storeList,
              preferredStore: preferredStore,
            );
          }
          else {
            return CenteredLoadingCircle(
              height: Measure.screenHeightFraction(context, .2),
              width: Measure.screenWidthFraction(context, .4),
            );
          }
        },
      ),
    );
  }
}

// https://api.flutter.dev/flutter/material/DropdownButton-class.html
class _StoreDropDown extends StatefulWidget {

  final List<Store> storeList;
  final Store preferredStore;

  _StoreDropDown({Key key, this.storeList, this.preferredStore}) : super(key: key);

  @override
  _StoreDropDownState createState() => _StoreDropDownState();
}

class _StoreDropDownState extends State<_StoreDropDown> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  String generalAddressValue;
  String storeAddressValue;
  List<String> uniqueGeneralAddresses;
  List<Store> matchingStores;
  String submitMessage;

  bool errorOccurred = false;

  static String saveSuccessMessage = 'Your location has been saved.';
  static String errorMessage = 'There was an error saving your location.';

  @override
  void initState() {
    uniqueGeneralAddresses = uniqueCityStateZip();
    String startingGeneralAddress = 
      widget.preferredStore?.cityStateZip ?? uniqueGeneralAddresses[0];
    generalAddressValue = startingGeneralAddress;

    matchingStores = allMatchingStores(generalAddressValue);
    storeAddressValue = 
      widget.preferredStore?.nameWithStreetAddress ?? matchingStores[0].nameWithStreetAddress;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    double itemHeight = 0.13;

    List<Widget> columnChildren = [
      Text('Location'),
      DropdownButton(
        itemHeight: Measure.screenHeightFraction(context, itemHeight),
        isExpanded: true,
        underline: Container(
          height: 2,
          color: Colors.blueGrey,
        ),
        value: generalAddressValue,
        items: uniqueGeneralAddresses
          .map<DropdownMenuItem<String>>(
            (value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value)
              );
            }
        ).toList(), 
        onChanged: (String newValue) {
          generalAddressValue = newValue;
          matchingStores = allMatchingStores(generalAddressValue);
          storeAddressValue = matchingStores[0].nameWithStreetAddress;
          setState(() {});
        }
      ),
      Padding(padding: EdgeInsets.all(10)),
      Text('Find Store'),
      DropdownButton(
        itemHeight: Measure.screenHeightFraction(context, itemHeight),
        isExpanded: true,
        underline: Container(
          height: 2,
          color: Colors.blueGrey,
        ),
        value: storeAddressValue,
        items: matchingStores
          .map<DropdownMenuItem<String>>((Store store) {
            String nameWithStreetAddress = store.nameWithStreetAddress;

            return DropdownMenuItem<String>(
              value: nameWithStreetAddress,
              child: Text(nameWithStreetAddress)
            );
          }
        ).toList(),
        onChanged: (String newValue) {
          setState(() {
            storeAddressValue = newValue;
          });
        },
      ),
      Padding(padding: EdgeInsets.all(10)),
      ElevatedButton(
        onPressed: () async {
          errorOccurred = false;

          Text message;

          Store newStore = getMatchingStore(storeAddressValue, generalAddressValue);

          if (newStore == null) {
            errorOccurred = true;
          }
          else {
            await db.updateUserPreferredLocation(newStore)
            .catchError((error) {
              errorOccurred = true;
            });
          }

          if (!errorOccurred) {
            message = Text(saveSuccessMessage, style: TextStyle(color: Colors.green));
          }
          else {
            message = Text(errorMessage, style: TextStyle(color: Colors.red));
          }

          Scaffold.of(context).showSnackBar(SnackBar(content: message));
          setState(() {});
        }, 
        child: Text('Save')
      )
    ];

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }

  List<String> uniqueCityStateZip() {

    List<String> unique = [];

    widget.storeList.forEach(
      (Store store) { 
        if (!unique.contains(store.cityStateZip)) {

          unique.add(store.cityStateZip);
        }
      }
    );

    unique.sort();

    return unique;
  }

  List<Store> allMatchingStores(String cityStateZip) {

    List<Store> matches = widget.storeList.where(
      (store) => store.cityStateZip == cityStateZip
    ).toList();

    matches.sort((a, b) => a.nameWithStreetAddress.compareTo(b.nameWithStreetAddress));
    return matches;
  }

  Store getMatchingStore(String nameWithStreetAddress, String cityStateZip) {

    Store match = widget.storeList.firstWhere(
      (Store store) {

        return store.nameWithStreetAddress == nameWithStreetAddress 
          && store.cityStateZip == cityStateZip;
      },
      orElse: () => null
    );

    return match;
  }

}

