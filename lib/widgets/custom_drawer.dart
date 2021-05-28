import 'dart:developer';

import 'package:agconnect_crash/agconnect_crash.dart';
import 'package:flutter/material.dart';
import 'package:forks_and_spoons/main.dart';
import 'package:forks_and_spoons/utils/data.dart';
import 'package:forks_and_spoons/widgets/checkout/order_page.dart';
import 'package:huawei_account/huawei_account.dart';
import 'package:huawei_analytics/huawei_analytics.dart';

class CustomDrawer extends StatefulWidget {
  final String userImage;
  final String userName;
  final bool isSignedIn;
  final Function signOut;
  final HMSAnalytics hmsAnalytics;

  CustomDrawer(
      {this.userImage,
      this.userName,
      this.isSignedIn = false,
      this.signOut,
      this.hmsAnalytics});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _totalPrice = 0;
  String _userName;
  String _userImage;
  HMSAnalytics _hmsAnalytics;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userImage = widget.userImage;
    _hmsAnalytics = widget.hmsAnalytics;
  }

  /// Huawei Account
  ///
  /// Get Auth Result
  void _getAuthResult() async {
    if (!widget.isSignedIn)
      log("Please Sign In First.");
    else if (_userName == null || _userName.isEmpty) {
      try {
        AuthAccount _id = await AccountAuthManager.getAuthResult();
        log(_id.givenName.toString());
        setState(() {
          // Add name.
          _userName = _id.givenName.isEmpty ? _id.displayName : _id.givenName;
          // Add surname.
          _userName =
              _userName + " " + (_id.familyName.isEmpty ? "" : _id.familyName);
          _userImage = _id.avatarUri;
        });
      } catch (e, stacktrace) {
        AGCCrash.instance.recordError(e.message, stacktrace);
        log("Error while obtaining Auth Result, $e");
        setState(() {
          _userName = " ";
        });
      }
    }
  }

  /// Huawei Analytics
  ///
  /// Predefined Event
  void deleteProductFromCartEvent(String productName) async {
    // Creating predefined event
    String name = HAEventType.DELPRODUCTFROMCART;
    Map<String, dynamic> value = {
      HAParamType.PRODUCTNAME: productName,
    };

    // Sending an event
    await _hmsAnalytics.onEvent(name, value);
  }

  /// Huawei Analytics
  ///
  /// Predefined Event
  void completePurchaseEvent() async {
    // Creating predefined event
    String name = HAEventType.COMPLETEPURCHASE;
    Map<String, dynamic> value = {};
    widget.isSignedIn
        ? value["userName"] = _userName
        : value["isSignedIn"] = widget.isSignedIn;

    // Sending an event
    await _hmsAnalytics.onEvent(name, value);
  }

  @override
  Widget build(BuildContext context) {
    _totalPrice = 0;
    _getAuthResult();
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
              child: Column(
            children: <Widget>[
              Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/logo.png",
                      color: Colors.black,
                    ),
                    Text(
                      "Forks &\nSpoons",
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Bon Appetit, ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300)),
                      Text(
                        _userName == null ? "" : _userName,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  CircleAvatar(
                    radius: 35,
                    child: ClipOval(
                      child: _userImage == null || _userImage.isEmpty
                          ? Image.asset("assets/duck.jpg")
                          : Image.network(_userImage),
                    ),
                    backgroundImage: AssetImage("assets/duck.jpg"),
                    backgroundColor: Colors.white,
                  ),
                ],
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your Order: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 0.0),
                      shrinkWrap: true,
                      itemCount: MyHomePage.userChoices.length,
                      itemBuilder: (BuildContext context, int index) {
                        _totalPrice +=
                            (productPrices[MyHomePage.userChoices[index]] *
                                    ((100 - MyHomePage.discount) / 100))
                                .toInt();
                        int currentProductPrice =
                            (productPrices[MyHomePage.userChoices[index]] *
                                    ((100 - MyHomePage.discount) / 100))
                                .toInt();
                        return Dismissible(
                            direction: DismissDirection.startToEnd,
                            key: UniqueKey(),
                            onDismissed: (DismissDirection direction) {
                              /// Sending "delete from cart" event.
                              deleteProductFromCartEvent(
                                  MyHomePage.userChoices[index]);
                              setState(() {
                                MyHomePage.userChoices.removeAt(index);
                              });
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text((MyHomePage.userChoices[index])),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40.0),
                                        child: Text("\$" +
                                            (currentProductPrice.toString())),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Divider(),
                                  ),
                                  index == MyHomePage.userChoices.length - 1
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 40.0),
                                              child: Text(
                                                "\$" + _totalPrice.toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ));
                      }),
                ), // Last Item
                MyHomePage.userChoices.length > 0
                    ? ((widget.isSignedIn)
                        ? ElevatedButton(
                            onPressed: () {
                              // Sending "complete purchase" event.
                              completePurchaseEvent();
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderPage(
                                            userChoices: MyHomePage.userChoices,
                                          )));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.grey)),
                            ),
                            child: Text("Order Now"),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Please log in first to order.\n.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ))
                    : SizedBox.shrink(),
              ],
            ),
          ),
          widget.isSignedIn
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // If signed in
                    ElevatedButton(
                      onPressed: () {
                        widget.signOut();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
