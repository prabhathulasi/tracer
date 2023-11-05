import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/data/provider/driver_journey_provider.dart';
import 'package:tracer/data/provider/inspection_provider.dart';
import 'package:tracer/data/provider/login_provider.dart';
import 'package:tracer/screen/createjourneyscreen.dart';
import 'package:tracer/screen/driver/driverhomescreen.dart';
import 'package:tracer/screen/driver/driverjourneyscreen.dart';
import 'package:tracer/screen/drivervehicleinspscreen.dart';
import 'package:tracer/screen/homescreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/widget/mytextstyle.dart';

String? loginstatus;
String? userType;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  loginstatus = prefs.getString("status");
  userType = prefs.getString("usertype");
  if (loginstatus == null) {
    loginstatus = "0";
    userType = "0"; // set an initial value
  }
  runApp(const MyApp());
}

// class FirebaseNotifications {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

//   void setUpFirebase() {
//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         // Handle the foreground notification here
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         // Handle the notification when the app is terminated
//       },
//       onResume: (Map<String, dynamic> message) async {
//         // Handle the notification when the app is in the background
//       },
//     );
//   }

//   // Additional methods to subscribe to topics, get FCM token, etc.
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static double letterSpacing = 0.6;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(93.8, 166.8),
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => LoginProvider(),
              ),
              ChangeNotifierProvider(
                create: (context) => InspectionProvider(),
              ),
              ChangeNotifierProvider(
                create: (context) => DriverJourneyProvider(),
              ),
            ],
            child: MaterialApp(
              title: 'Tracer App',
              theme: ThemeData(
                fontFamily: GoogleFonts.titilliumWeb().fontFamily,

                textTheme: TextTheme(
                  headline1: MyTextStyle.bigHeadingTextStyle,
                  headline2: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  headline3: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: const Color(0xFFb0edff),
                      fontWeight: FontWeight.w700,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  headline4: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: const Color(0xFFb0edff),
                      fontWeight: FontWeight.w100,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  headline5: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  headline6: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  subtitle2: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  subtitle1: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  bodyText1: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  bodyText2: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  overline: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  caption: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                  button: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ),
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: const Color.fromARGB(255, 24, 74, 87),
              ),
              initialRoute: loginstatus == "0"
                  ? '/'
                  : userType == "1"
                      ? "/homescreen"
                      : "/driverscreen",
              routes: {
                '/': (context) => ProgressHUD(
                      child: const LoginScreen(),
                    ),
                '/homescreen': (context) => ProgressHUD(
                      child: const HomeScreenPage(),
                    ),
                '/createjourneyscreen': (context) => ProgressHUD(
                      child: const CreateJourneyScreenPage(),
                    ),
                '/driverscreen': (context) => ProgressHUD(
                      child: const DriverHomeScreenPage(),
                    ),
                '/driverjourneyscreen': (context) => ProgressHUD(
                      child: const DriverJourneyScreenPage(),
                    ),
                '/drivervehiclescreen': (context) => ProgressHUD(
                      child: const DriverVehicleInspectionScreenPage(
                        journeyID: '',
                      ),
                    ),

                /*'/otpverification': (context) => OTPVerificationPage(),
              '/referrallist': (context) => ReferralList(),
              '/digitalcard': (context) => DigitalCardPage(),
              '/activitiescatitem': (context) => ActivitiesCatItemPage(),
              '/activitiessessions': (context) => ActivitiesSessionsPage(),
              '/menupage': (context) => MenuPage(),
              '/homescreen': (context) => BottomNavigation5Page(),
              '/homemenuscreen': (context) => HomeMenuScreen(),
              '/attendance_list': (context) => AttendanceList(),*/
              },
            ),
          );
        });
  }
}
