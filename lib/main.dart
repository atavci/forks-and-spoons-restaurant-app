import 'dart:async';
import 'dart:developer';

import 'package:agconnect_crash/agconnect_crash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:forks_and_spoons/widgets/custom_drawer.dart';
import 'package:forks_and_spoons/widgets/product/product_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_account/huawei_account.dart';
import 'package:huawei_analytics/huawei_analytics.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_push/huawei_push_library.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'utils/data.dart';
import 'widgets/carousel/carousel.dart';
import 'widgets/product/product_card.dart';

// If you are using Flutter version 1.17 or lower, please use the following code:
// void main() {
//   // Obtains an instance of AGCCrash.
//   AGCCrash _agcCrashInstance = AGCCrash.instance;

//   // Defines Crash Service's [onFlutterError] API as Flutter's.
//   FlutterError.onError = _agcCrashInstance.onFlutterError;

//   // Below configuration records all exceptions that occurs in your app.
//   // For detailed information please visit
//   // [https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agc-crash-flutter-usage-0000001063046945#ZH-CN_TOPIC_0000001063046945__section1371315351334?ha_source=hms1]
//   runZoned<Future<void>>(() async {
//     runApp(MyApp(_agcCrashInstance));
//   }, onError: (dynamic error, StackTrace stackTrace) {
//     AGCCrash.instance.recordError(error, stackTrace);
//   });
// }

void main() {
  // Obtains an instance of AGCCrash.
  AGCCrash _agcCrashInstance = AGCCrash.instance;

  // Defines Crash Service's onFlutterError API as Flutter's.
  FlutterError.onError = _agcCrashInstance.onFlutterError;

  // Below configuration records all exceptions that occurs in your app.
  // For detailed information please visit
  // [https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agc-crash-flutter-usage-0000001063046945#ZH-CN_TOPIC_0000001063046945__section1371315351334?ha_source=hms1]
  runZonedGuarded<Future<void>>(() async {
    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) {
    print("An exception occurred");
    AGCCrash.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  HMSAnalytics hmsAnalytics = HMSAnalytics();

  /// Initialization methods for Huawei Analytics.
  void initAnalytics() async {
    // Shows Debug level logs for Huawei Analytics.
    await hmsAnalytics.enableLogWithLevel("DEBUG");

    // Enables Huawei Analytics.
    await hmsAnalytics.setAnalyticsEnabled(true);

    // Minimum time interval for reporting events .
    await hmsAnalytics.setReportPolicies(scheduledTime: 60);

    // Gets AAID for user identification.
    String userAAID = await hmsAnalytics.getAAID();

    // Sets user profile for uniquely defining a user.
    await hmsAnalytics.setUserProfile("user", userAAID);

    // Sets AAID as user ID.
    AGCCrash.instance.setUserId(userAAID);
  }

  /// Initialization methods for Huawei Crash Service.
  void initCrashService() async {
    // Enables the crash collection.
    AGCCrash.instance.enableCrashCollection(true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initAnalytics();
    initCrashService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        log('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        log('appLifeCycleState resumed');
        Push.cancelScheduledNotifications();
        break;
      case AppLifecycleState.paused:
        log('appLifeCycleState paused');
        if (MyHomePage.userChoices.length > 0 &&
            state == AppLifecycleState.paused) {
          log('Sending sceduled local notification.');
          Push.localNotificationSchedule({
            HMSLocalNotificationAttr.TITLE: 'You forgot your meal in the cart.',
            HMSLocalNotificationAttr.MESSAGE:
                "It is better for your meal to stay in your stomach rather than the cart.",
            HMSLocalNotificationAttr.FIRE_DATE:
                DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch,
            HMSLocalNotificationAttr.ALLOW_WHILE_IDLE: true,
            HMSLocalNotificationAttr.TAG: "notify_cart"
          });
        }
        break;
      case AppLifecycleState.detached:
        log('appLifeCycleState suspending');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget widget) {
        Widget error = Container(
          height: double.infinity,
          width: double.infinity,
          child: Text(
            '...rendering error...',
            style: TextStyle(color: Colors.white),
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/duck.jpg'),
            repeat: ImageRepeat.repeat,
          )),
        );
        if (widget is Scaffold || widget is Navigator)
          error = Scaffold(body: Center(child: error));
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          print("Widget Error Occurred");
          AGCCrash.instance
              .recordError(errorDetails.exception, errorDetails.stack);
          return error;
        };
        return widget;
      },
      title: 'Forks&Spoons',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(
        hmsAnalytics: hmsAnalytics,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static List<String> userChoices = [];
  static int discount = 0;
  final HMSAnalytics hmsAnalytics;

  MyHomePage({Key key, this.hmsAnalytics}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSignedIn = false;
  AuthAccount _id;
  Map user;
  String newYorkSteakPic = "";
  int discount = 0;

  /// Permission Handler of Huawei Location.
  PermissionHandler permissionHandler;

  @override
  void initState() {
    super.initState();
    initPush();
    permissionHandler = PermissionHandler();
  }

  /// HMS Push
  ///
  /// Initialize.
  void initPush() async {
    if (!mounted) return;
    Push.setAutoInitEnabled(true);

    // Subscribe to the streams. (Token, Intent and Data Message)
    Push.getTokenStream.listen(_onTokenEvent, onError: _onTokenError);
    Push.getIntentStream.listen(_onNewIntent, onError: _onIntentError);
    // Handles startup intents.
    _onNewIntent(await Push.getInitialIntent());
    Push.onMessageReceivedStream
        .listen(_onMessageReceived, onError: _onMessageReceiveError);

    // Get the push token.
    Push.getToken("");
  }

  /// HMS Push
  ///
  /// Listen to new token events.
  void _onTokenEvent(String token) {
    log("Obtained push token: $token");
  }

  /// HMS Push
  ///
  /// Handle token errors.
  void _onTokenError(Object error) {
    PlatformException e = error;
    print("TokenErrorEvent: " + e.message);
  }

  /// HMS Push
  ///
  /// Listen to new data messages.
  void _onMessageReceived(RemoteMessage remoteMessage) {
    String data = remoteMessage.data;

    if (remoteMessage.dataOfMap.containsKey("discount")) {
      setState(() {
        discount = int.parse(remoteMessage.dataOfMap['discount']);
        MyHomePage.discount = discount;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
            title: Text(
              "Discount for your pocket, Best food for your stomach!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Congrats you have received a ${remoteMessage.dataOfMap['discount']}% discount.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                MaterialButton(
                    onPressed: () => Navigator.pop(context), child: Text("OK"))
              ],
            )),
      );
    }

    /// Extra Features ///
    /// -------------- ///
    ///
    /// You can change New York Steak product picture by sending a data message with a format `{"newYorkSteak":"<image_url>"}`
    /// An example image url is `https://www.shoprite.co.zm/content/dam/ShopriteZambia/Websites/ShopriteZambia/butchery-africa/img/beef-steak.png`
    // if (remoteMessage.dataOfMap.containsKey("newYorkSteak")) {
    //   setState(() {
    //     newYorkSteakPic = remoteMessage.dataOfMap["newYorkSteak"];
    //   });
    // }
    ///
    /// You can also send a local notification from this callback.
    // Push.localNotification({
    // HMSLocalNotificationAttr.TITLE: 'DataMessage Received',
    // HMSLocalNotificationAttr.MESSAGE: data
    // });
    log("onRemoteMessageReceived Data: " + data);
  }

  /// HMS Push
  ///
  /// Handle data message errors.
  void _onMessageReceiveError(Object error) {
    PlatformException e = error;
    log("onRemoteMessageReceiveError: " + e.message);
  }

  /// HMS Push
  ///
  /// Handle new intents.
  void _onNewIntent(String intentString) {
    // The Custom Intent URI that is sent from the AppGalleryConnect
    // is starts by the prefix `app://` as it is defined on the AndroidManifest.xml
    intentString = intentString ?? '';
    if (intentString != '') {
      log('CustomIntentEvent: $intentString');
      List parsedString = intentString.split("://");
      if (parsedString[1] == "NewYorkSteak") {
        // Opens the NewYork Steak Info Dialog.
        Navigator.push(
            context,
            PageRouteBuilder(
                opaque: false,
                barrierDismissible: true,
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return new FadeTransition(
                      opacity: new CurvedAnimation(
                          parent: animation, curve: Curves.easeOut),
                      child: child);
                },
                pageBuilder: (BuildContext context, _, __) {
                  return ProductDialog(
                    productName: "New York",
                    imagePath: "assets/menu/steak1.png",
                    productDesc: productDetails['New York'],
                  );
                }));
      }
    }
  }

  /// HMS Push
  ///
  /// Handle custom intent errors.
  void _onIntentError(Object err) {
    PlatformException e = err;
    print("Error on intent stream: " + e.toString());
  }

  /// Huawei Account
  ///
  /// Sign In to HUAWEI ID
  void _signIn(BuildContext context) async {
    // This parameter is optional. You can run the method with default options.
    final helper = new AccountAuthParamsHelper();
    helper
      ..setIdToken()
      ..setAccessToken()
      ..setAuthorizationCode()
      ..setEmail()
      ..setProfile();
    try {
      _id = await AccountAuthService.signIn(helper);
      log("Sign In User: ${_id.displayName}");
      setState(() {
        isSignedIn = true;
      });

      // Optionally verify the id.
      await performServerVerification(_id.idToken);

      // Sets user name as custom key while sending crash reports.
      AGCCrash.instance.setCustomKey("userName", _id.displayName);

      // Requests location permissions from the signed in user.
      requestLocationPermissions();
    } on PlatformException catch (e, stacktrace) {
      AGCCrash.instance.recordError(e, stacktrace);
      log("Sign In Failed!, Error is:${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Could not log in to your account."),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// Huawei Account
  ///
  /// ID Verification
  Future<void> performServerVerification(String idToken) async {
    var response = await http.post(
        "https://oauth-login.cloud.huawei.com/oauth2/v3/tokeninfo",
        body: {'id_token': idToken});
    print(response.body);
  }

  /// Huawei Account
  ///
  /// Sign Out
  void _signOut() async {
    try {
      final bool result = await AccountAuthService.signOut();
      log("Signed out: $result");
      setState(() {
        isSignedIn = false;
      });

      // Deletes user name from custom keys.
      AGCCrash.instance.setCustomKey("userName", null);
    } on PlatformException catch (e, stacktrace) {
      AGCCrash.instance.recordError(e.message, stacktrace);
      log("Error while signing out $e");
    }
  }

  /// Huawei Analytics
  ///
  /// Predefined Event
  void addToCartEvent(String category, String productName) async {
    // Creating predefined event
    String name = HAEventType.ADDPRODUCT2CART;
    dynamic value = {
      HAParamType.CATEGORY: category,
      HAParamType.PRODUCTNAME: productName,
    };

    // Sending an event
    await widget.hmsAnalytics.onEvent(name, value);
  }

  /// Huawei Analytics
  ///
  /// Predefined Event
  void startCheckoutEvent() async {
    // Creating predefined event
    String name = HAEventType.STARTCHECKOUT;
    Map<String, dynamic> value = {
      "isUserSignedIn": isSignedIn,
    };

    // Sending an event
    await widget.hmsAnalytics.onEvent(name, value);
  }

  /// Test method for sending an exception record to the agcrash service.
  void sendException() {
    try {
      // Throws intentional exception for testing.
      throw Exception("Error occured.");
    } catch (error, stackTrace) {
      // Records the occured exception.
      AGCCrash.instance.recordError(error, stackTrace);
    }
  }

  /// Method for checking and requesting location permissions from user.
  requestLocationPermissions() async {
    if (!await permissionHandler.hasLocationPermission()) {
      await permissionHandler.requestLocationPermission();
    }

    if (!await permissionHandler.hasBackgroundLocationPermission()) {
      await permissionHandler.requestBackgroundLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
      drawer: CustomDrawer(
        isSignedIn: isSignedIn,
        signOut: _signOut,
        hmsAnalytics: widget.hmsAnalytics,
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
            backgroundColor: Colors.black,
            child: Center(
              child: Stack(
                children: <Widget>[
                  Icon(
                    OMIcons.shoppingCart,
                    color: Colors.white,
                  ),
                  MyHomePage.userChoices.length > 0
                      ? Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 10,
                              minHeight: 10,
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
            onPressed: () {
              // Sending "start checkout" event.
              startCheckoutEvent();

              // Throwing intentional exception for testing Crash Service.
              sendException();
              Scaffold.of(context).openDrawer();
            });
      }),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Image.asset(
                "assets/logo.png",
                color: Colors.black,
              ),
              Text(
                "Forks &\nSpoons",
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        ),
        actions: <Widget>[
          isSignedIn
              ? Center(
                  child: Text(_id.givenName.isEmpty
                      ? _id.displayName
                      : _id.givenName + " " + _id.familyName),
                )
              : InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    /// HMS Account - SignIn
                    _signIn(context);
                  }),
          SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          CustomCarousel(),
          SizedBox(
            height: 10,
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                // Product Details
                String category = products.keys.elementAt(index);
                String productName =
                    products.values.elementAt(index).keys.first;
                String productDesc =
                    productDetails[products.values.elementAt(index).keys.first];
                int productPrice =
                    productPrices[products.values.elementAt(index).keys.first];
                String imgPath = products.values.elementAt(index).values.first;
                bool isUrlImg = false;

                // Changing New York Steak Img with DataMessage.
                if (productName == "New York") {
                  if (newYorkSteakPic.isNotEmpty) {
                    imgPath = newYorkSteakPic;
                    isUrlImg = true;
                  }
                }

                // Product Card for UI.
                return ProductCard(
                    hmsAnalytics: widget.hmsAnalytics,
                    category: category,
                    productName: productName,
                    imagePath: imgPath,
                    isUrlImg: isUrlImg,
                    productDesc: productDesc,
                    productPrice: productPrice,
                    discount: discount,
                    onTapAddToCart: () {
                      /// Sending "add to cart" event.
                      addToCartEvent(category, productName);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(productName + " is added to your cart.")));

                      // Adding product to user choices.
                      setState(() {
                        MyHomePage.userChoices.add(productName);
                      });
                    });
              })
        ],
      )),
    );
  }
}
