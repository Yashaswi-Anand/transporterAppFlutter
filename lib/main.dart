import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:liveasy/constants/color.dart';
import 'package:liveasy/providerClass/providerData.dart';
import 'package:get/get.dart';
import 'package:liveasy/screens/errorScreen.dart';
import 'package:liveasy/screens/languageSelectionScreen.dart';
import 'package:liveasy/screens/noInternetScreen.dart';
import 'package:liveasy/screens/spashScreenToGetTransporterData.dart';
import 'package:liveasy/translations/l10n.dart';
import 'package:liveasy/widgets/splashScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity/connectivity.dart';

import 'functions/trasnporterApis/runTransporterApiPost.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await GetStorage.init();
  await GetStorage.init('TransporterIDStorage');
  await FlutterConfig.loadEnvVariables();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _connectionStatus = "Unknown";
  late Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    configOneSignel();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {});
      } else if (result == ConnectivityResult.none) {
        Get.to(NoInternetScreen());
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void configOneSignel() {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("b1948857-b2d1-4946-b4d1-86f911c30389");
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: ChangeNotifierProvider<ProviderData>(
        create: (context) => ProviderData(),
        builder: (context, child) {
          return FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                final provider = Provider.of<ProviderData>(context);
                if (snapshot.connectionState == ConnectionState.done) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return GetMaterialApp(
                      builder: EasyLoading.init(),
                      theme: ThemeData(fontFamily: "montserrat"),
                      locale: provider.locale,
                      supportedLocales: L10n.all,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                      ],
                      home: SplashScreen(),
                    );
                  } else{
                    /*FirebaseAuth.instance.currentUser!.updateDisplayName(tidstorage.read('lang'));
                    print("===========main file=====------- ${provider.locale}");
                    print(Locale("en"));
                    String lg = FirebaseAuth.instance.currentUser!.displayName!;
                    print(lg);*/
                    //String bhasha = provider.locale == null ?
                      //          FirebaseAuth.instance.currentUser!.displayName.toString() : provider.locale.toString();
                    //print("bhash :$bhasha");

                    return GetMaterialApp(
                      builder: EasyLoading.init(),
                      theme: ThemeData(
                          fontFamily: "montserrat",
                          appBarTheme: AppBarTheme(
                              color: statusBarColor,
                              iconTheme: IconThemeData(color: grey))),
                      locale: provider.locale,//Locale(lg),
                      supportedLocales: L10n.all,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                      ],
                      home: SplashScreenToGetTransporterData(
                        mobileNum: FirebaseAuth
                            .instance.currentUser!.phoneNumber
                            .toString()
                            .substring(3, 13),
                      ),
                    );
                  }
                } else
                  return ErrorScreen();
              });
        },
      ),
    );
  }
}
