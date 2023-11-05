import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tracer/screen/dashboardscreen.dart';
import 'package:tracer/screen/historyscreen.dart';
import 'package:tracer/screen/livejourneyscreen.dart';
import 'package:tracer/screen/notificationscreen.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  // initialize global widget

  late PageController _pageController;

  // Pages if you click bottom navigation
  final List<Widget> _contentPages = <Widget>[
    ProgressHUD(
      child: const DashboardScreenPage(),
    ),
    ProgressHUD(
      child: const LiveJourneyScreenPage(),
    ),
    ProgressHUD(
      child: const HistoryScreenPage(),
    ),
    ProgressHUD(
      child: const NotificationScreenPage(),
    ),
  ];

  @override
  void initState() {
    // set initial pages for navigation to home page
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          /*appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Home Screen",
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),*/
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _contentPages.map((Widget content) {
              return content;
            }).toList(),
          ),
          bottomNavigationBar: ConvexAppBar(
            style: TabStyle.flip,
            height: 60,

            backgroundColor: const Color.fromARGB(255, 6, 30, 35),
            color: const Color(0xffb0edff),
            activeColor: const Color(0xffb0edff),
            items: const [
              TabItem(icon: FontAwesomeIcons.gauge, title: 'Dashboard'),
              TabItem(icon: LucideIcons.radio, title: 'Live Journey'),
              TabItem(icon: LucideIcons.history, title: 'History'),
              TabItem(icon: LucideIcons.bell, title: 'Notification'),
            ],
            initialActiveIndex: 0, //optional, default as 0
            onTap: (int i) {
              _tapNav(i);
            },
          ),
        ));
  }

  void _tapNav(index) {
    _pageController.jumpToPage(index);

    // this unfocus is to prevent show keyboard in the text field
    FocusScope.of(context).unfocus();
  }
}
