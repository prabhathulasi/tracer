import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/common/connectivity.dart';
import 'package:tracer/data/model/drivermodel.dart';
import 'package:tracer/data/model/filtermodel.dart';
import 'package:tracer/data/model/locationmodel.dart';
import 'package:tracer/data/model/routemodel.dart';
import 'package:tracer/data/model/vehiclemodel.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/customalert.dart';
import 'package:tracer/widget/customiconradiobutton.dart';
import 'package:tracer/widget/locationdialog.dart';
//import 'package:dropdown_search/dropdown_search.dart';
import 'package:tracer/widget/mydialog.dart';

import 'dart:async';
import 'dart:math';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:tracer/widget/mytextstyle.dart';

const kGoogleApiKey = "AIzaSyC27LvX7JBRS24R7-IkcFS5SQo2mZ63r9g";

class CreateJourneyScreenPage extends StatefulWidget {
  const CreateJourneyScreenPage({super.key});
  //final GlobalKey<_CreateJourneyScreenPageState> key = GlobalKey();
  @override
  _CreateJourneyScreenPageState createState() =>
      _CreateJourneyScreenPageState();
}

final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _CreateJourneyScreenPageState extends State<CreateJourneyScreenPage> {
  String? token;
  late Response response;

  int? _selectedRadio;
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  List<Driver> names = [];
  List<Vehicle> vehiclenames = [];
  final IconData _iconVisible = Icons.search;
  final TextEditingController _textFieldController = TextEditingController();
  final Color _color5 = const Color(0xFFFFFFFF);
  Driver? selectedName;
  Vehicle? selectedVehicle;
  String _selectedDriverFilter = "0";
  String _selectedVehicleFilter = "1";
  List<FilterModel> driverFilter = [];
  List<FilterModel> vehicleFilter = [];
  List<FilterModel> savedDriverFilter = [];
  String _vehicleName = "";
  String _driverName = "";
  String _driverID = "";
  String _vehicleID = "";
  TextEditingController _startLocationCtrllor = TextEditingController();
  TextEditingController _endLocationCtrllor = TextEditingController();

  Mode? _mode = Mode.overlay;

  final List<LocationModel> _routeLocations = [];
  late List<LocationModel> selectedRouteArr = [];

  late String _hour, _minute, _time;

  late String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

  String departureTime = "";

  String departureTimeLbl = "";

  late int departureTimeEPOC;

  String distanceStr = "";

  late int totDuration;

  late int etArrivalEPOC;

  String etArrival = "";

  late DateTime originalDateTime;

  late DateFormat formatter;

  String distancetxt = "";

  String durationtxt = "";

  late int totDurationInSeconds;

  late List<LocationModel> journeyRoute = [];
  bool isInternet = true;
  @override
  void initState() {
    super.initState();

    selectedName = null;
    _selectedRadio = 1;
    connectioncheck();
    getSharedPrefenceVal();
  }

  connectioncheck() async {
    if (await ConnectivityCheck().isInternetAvailable()) {
      isInternet = true;
    } else {
      isInternet = false;
    }
  }

  getSharedPrefenceVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    getDriverFilterData();
    getVehicleFilterData();
    loadDrivers();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primaryColor: Colors.brown,
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
              colorScheme: const ColorScheme.light(primary: Color(0xff0f5164))
                  .copyWith(secondary: Colors.blue),
            ),
            child: child!,
          );
        },
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        departureTime = "${DateFormat("yyyy-MM-dd").format(selectedDate)} ";
        departureTimeLbl = "${DateFormat("dd MMM").format(selectedDate)} ";
      });
      _selectTime(context);
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.brown,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme.light(primary: Color(0xff0f5164))
                .copyWith(secondary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = '$_hour : $_minute';

        departureTime += formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, ":00 ", am]).toString();
        formatter = DateFormat("yyyy-MM-dd hh:mm:ss a");
        originalDateTime = formatter.parse(departureTime);
        departureTimeLbl += formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        ;
        departureTimeEPOC = (originalDateTime.millisecondsSinceEpoch ~/ 1000);
      });
    }
  }

  getDriverFilterData() async {
    FilterModel fModel = FilterModel(id: 0, name: "All drivers", isFav: false);
    driverFilter.add(fModel);
    fModel = FilterModel(id: 1, name: "Only available drivers", isFav: false);
    driverFilter.add(fModel);
    fModel = FilterModel(id: 2, name: "Only compliant drivers", isFav: false);
    driverFilter.add(fModel);
    fModel = FilterModel(
        id: 3, name: "Only available and compliant drivers", isFav: false);
    driverFilter.add(fModel);
  }

  getVehicleFilterData() async {
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "4"});
    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);

    try {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      vehicleFilter = (jsonMap['p'] as List<dynamic>)
          .map((e) => FilterModel.fromJson(e))
          .toList();
    } catch (e) {
      names.clear();
    }
  }

  Future<void> loadDrivers() async {
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "2"});
    data.addAll({'p[type]': _selectedDriverFilter});
    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);

    try {
      //var dataVal =
      //    (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      names = (jsonMap['p'] as List<dynamic>)
          .map((e) => Driver.fromJson(e))
          .toList();
    } catch (e) {
      names.clear();
    }
  }

  Future<void> loadVehicles() async {
    String url = TracerApis.login + "?controller=jm_manager";

    Map<String, dynamic> data = {};
    data.addAll({'c': "3"});
    data.addAll({'p[type]': "0"});
    data.addAll({'p[veh_type]': _selectedVehicleFilter});
    data.addAll({'t': "0"});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);

    try {
      //var dataVal =
      //    (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

      vehiclenames = (jsonMap['p'] as List<dynamic>)
          .map((e) => Vehicle.fromJson(e))
          .toList();
    } catch (e) {
      vehiclenames.clear();
    }
  }

  void driverFilterPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return MyDialog(
              filterData: driverFilter,
              titleStr: "",
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDriverFilter = value;
          loadDrivers();
        });
      }
    });
  }

  Future<void> _searchLocation(String position) async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode!,
      language: "en",
      types: ["(cities)"],
      strictbounds: false,
      decoration: InputDecoration(
        hintText: position == 'START' ? 'Start Location' : 'End Location',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      components: [Component(Component.country, "in")],
    );

    displayPrediction(p, context, position);
  }

  Future<void> displayPrediction(
      Prediction? p, BuildContext context, String position) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      //final lat = detail.result.geometry!.location.lat;
      //final lng = detail.result.geometry!.location.lng;

      //ScaffoldMessenger.of(context).showSnackBar(
      //  SnackBar(content: Text("${p.description} - $lat/$lng")),
      //);

      if (position == "START") {
        _startLocationCtrllor.text = detail.result.name.toString();
      } else {
        _endLocationCtrllor.text = detail.result.name.toString();
        _getRoute();
      }
    }
  }

  convertDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds % 3600) ~/ 60;
    Duration duration = Duration(hours: hours, minutes: minutes);
    return duration;
  }

  void _getRoute() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    try {
      String directionsURL =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocationCtrllor.text}&destination=${_endLocationCtrllor.text}&key=${kGoogleApiKey}';
      http.Response directionsResponse =
          await http.get(Uri.parse(directionsURL));
      Map<String, dynamic> directionsData =
          json.decode(directionsResponse.body);
      List<dynamic> legs = directionsData['routes'][0]['legs'];
      distanceStr = legs[0]['distance']['value'].toString();
      distancetxt = legs[0]['distance']['text'].toString();
      durationtxt = legs[0]['duration']['text'].toString();

      totDurationInSeconds = legs[0]['duration']['value'];
      journeyRoute.clear();
      _routeLocations.clear();
      for (int i = 0; i < legs.length; i++) {
        List<dynamic> steps = legs[i]['steps'];
        for (int j = 0; j < steps.length; j++) {
          String latloc = steps[j]['start_location']['lat'].toString();
          String lonloc = steps[j]['start_location']['lng'].toString();
          String startLocation = latloc + ', ' + lonloc;
          String geocodingURL =
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=$startLocation&key=${kGoogleApiKey}';
          http.Response geocodingResponse = await http
              .get(Uri.parse(geocodingURL))
              .timeout(const Duration(seconds: 30));
          Map<String, dynamic> geocodingData =
              json.decode(geocodingResponse.body);
          List<dynamic> addressComponents =
              geocodingData['results'][0]['address_components'];
          String? placeLocality;
          String subLocality = "";
          for (int k = 0; k < addressComponents.length; k++) {
            if (addressComponents[k]['types'].contains('sublocality')) {
              subLocality = addressComponents[k]['long_name'];
            }
            if (addressComponents[k]['types'].contains('locality')) {
              placeLocality = addressComponents[k]['long_name'];
              break;
            }
          }

          LocationModel rModel = LocationModel(isFav: false);
          int currentind = j;
          rModel.seq = (currentind + 1).toString();
          if (j == 0) {
            rModel.type = "1";
          } else if (j == steps.length - 1) {
            rModel.type = "3";
          } else {
            rModel.type = "2";
          }
          rModel.lat = latloc;
          rModel.lon = lonloc;
          journeyRoute.add(rModel);

          setState(() {
            LocationModel lModel = LocationModel(isFav: false);
            lModel.lat = latloc;
            lModel.lon = lonloc;
            lModel.loc = "$subLocality ${placeLocality!}";

            _routeLocations.add(lModel);
          });
        }
      }
      progress?.dismiss();
    } catch (e) {
      progress?.dismiss();
    }
  }

  void vehicleFilterPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return MyDialog(
                filterData: vehicleFilter, titleStr: "Select Vehicle Type");
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedVehicleFilter = value;
          loadVehicles();
        });
      }
    });
  }

  void selectRoutes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return LocationDialog(locData: _routeLocations);
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedRouteArr.clear();
          selectedRouteArr.addAll(value);
        });
      }
    });
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage!)),
    );
  }

  Future<void> journeyConfirm() async {
    if (_vehicleID.isEmpty || _vehicleID == "") {
      customDialog("Error", "Choose Vehicle");
      return;
    } else if (_driverID.isEmpty || _driverID == "") {
      customDialog("Error", "Choose Driver");
      return;
    } else if (_startLocationCtrllor.text.isEmpty) {
      customDialog("Error", "Choose Start Location");
      return;
    } else if (_endLocationCtrllor.text.isEmpty) {
      customDialog("Error", "Choose End Location");
      return;
    } else if (departureTime.isEmpty || departureTime == "") {
      customDialog("Error", "Choose Start Date & time");
      return;
    } else if (selectedRouteArr.isEmpty) {
      customDialog("Error", "Choose Journey Routes");
      return;
    } /*else if (selectedRouteArr.length < 2) {
      customDialog("Error", "Journey Routes should be more than 2 points");
      return;
    }*/
    final progress = ProgressHUD.of(context);
    progress?.show();
    var dataVal;
    try {
      // Compute distance and duration using the distance matrix API
      String baseUrl =
          "https://maps.googleapis.com/maps/api/distancematrix/json?";
      String apiKey = "AIzaSyCRLIcLfQQycb8NUIC-992s9vasx73DpWE";
      String origins = "";
      String destinations = "";

      selectedRouteArr =
          selectedRouteArr.where((location) => location.isFav).toList();
      for (int i = 0; i < selectedRouteArr.length; i++) {
        selectedRouteArr[i].seq = (i + 1).toString();
        if (i == 0) {
          origins = "${selectedRouteArr[i].lat},${selectedRouteArr[i].lon}";
        } else if (i == selectedRouteArr.length - 1) {
          destinations =
              "$destinations${selectedRouteArr[i].lat},${selectedRouteArr[i].lon}";
        } else {
          destinations =
              "$destinations ${selectedRouteArr[i].lat},${selectedRouteArr[i].lon}|";
        }
      }
      String url =
          "${baseUrl}origins=$origins&destinations=$destinations&key=$apiKey";
      http.Response response = await http.get(Uri.parse(url));

      // Parse JSON response and extract distance and duration information
      var data = json.decode(response.body);

      List<dynamic> destinationAddresses = data["destination_addresses"];
      List<dynamic> elements = data["rows"][0]["elements"];
      for (int i = 0; i < destinationAddresses.length; i++) {
        selectedRouteArr[i + 1].dist =
            elements[i]["distance"]["value"].toString();
        int routeDuration =
            int.parse(elements[i]["duration"]["value"].toString()) ~/ 60;

        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(departureTimeEPOC * 1000);
        if (i != 0) {
          if (selectedRouteArr[i - 1].halt_dur != "0") {
            Duration duration = Duration(
                minutes:
                    int.parse(selectedRouteArr[i - 1].halt_dur.toString()));
            dateTime = dateTime.add(duration);
            originalDateTime = originalDateTime.add(duration);
          }
        } else {
          selectedRouteArr[i].dur = "0";
          selectedRouteArr[i].eta = "0";
          selectedRouteArr[i].dist = "0";
          selectedRouteArr[i].type = "1";
        }
        if (i == destinationAddresses.length - 1) {
          selectedRouteArr[i + 1].type = "3";
        } else {
          selectedRouteArr[i + 1].type = "2";
        }

        selectedRouteArr[i + 1].dur = routeDuration.toString();
        dateTime = dateTime.add(convertDuration(routeDuration));

        selectedRouteArr[i + 1].eta =
            (dateTime.millisecondsSinceEpoch ~/ 1000).toString();
      }

      originalDateTime =
          originalDateTime.add(convertDuration(totDurationInSeconds));
      etArrival = DateFormat('yyyy-MM-dd hh:mm:ss a').format(originalDateTime);
      etArrivalEPOC = (originalDateTime.millisecondsSinceEpoch ~/ 1000);
      totDuration = totDurationInSeconds ~/ 60;

      Map<String, dynamic> pData = {};

      //pData.addAll({'points_arr': jsonEncode(selectedRouteArr)});

      //Map<String, dynamic> journeyData = {};
      // journeyData.addAll({'points_arr': jsonEncode(journeyRoute)});
      // pData.addAll({'journey_route': journeyData});

      Map<String, dynamic> jsonData = {};
      jsonData.addAll({'c': "5"});

      //jsonData.addAll({'p': pData});
      jsonData.addAll({'p[veh_id]': _vehicleID});
      jsonData.addAll({'p[drv_id]': _driverID});
      jsonData.addAll({'p[start_time_epoc]': departureTimeEPOC.toString()});
      jsonData.addAll({'p[start_time_str]': departureTime});
      jsonData.addAll({'p[journey_dur_min]': totDuration.toString()});
      jsonData.addAll({'p[journey_dist_meters]': distanceStr});
      jsonData.addAll({'p[journey_eta_epoc]': etArrivalEPOC.toString()});
      jsonData.addAll({'p[journey_eta_str]': etArrival});
      int index = 0;

      selectedRouteArr.forEach((element) {
        jsonData.addAll({'p[points_arr][$index][seq]': element.seq});
        jsonData.addAll({'p[points_arr][$index][type]': element.type});
        jsonData.addAll({'p[points_arr][$index][lat]': element.lat});
        jsonData.addAll({'p[points_arr][$index][lon]': element.lon});
        jsonData.addAll({'p[points_arr][$index][loc]': element.loc});
        jsonData.addAll({'p[points_arr][$index][halt_dur]': element.halt_dur});
        jsonData.addAll({'p[points_arr][$index][dist]': element.dist});
        jsonData.addAll({'p[points_arr][$index][eta]': element.eta});
        jsonData.addAll({'p[points_arr][$index][dur]': element.dur});
        index++;
      });
      jsonData.addAll({'t': "0"});
      //jsonData.addAll({'debug': "yes"});
      //String jsonVal = jsonEncode(jsonData);

      //print(jsonVal);

      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";
      String jurl = TracerApis.login + "?controller=jm_manager";
      Response jresponse = await dio.post(jurl, queryParameters: jsonData);
      dataVal =
          (HandleResponse.handleRes(jresponse.data) as Map<String, dynamic>);
    } catch (e) {
      progress?.dismiss();
    }
    progress?.dismiss();

    if (dataVal['s'] == 0) {
      journeyClear();
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: "Success",
            message: "Journey created successfully",
            onPressed: () {
              Navigator.pop(context);
              //Navigator.pop(context);
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: "Error",
            message: dataVal['p']['message'].toString(),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  void journeyClear() {
    selectedName?.compliance?.clear();

    selectedVehicle?.compliance?.clear();
    _selectedDriverFilter = "0";
    _selectedVehicleFilter = "0";

    _vehicleName = "";
    _driverName = "";
    _driverID = "";
    _vehicleID = "";
    _startLocationCtrllor.text = "";

    _endLocationCtrllor.text = "";
    _routeLocations.clear();
    selectedRouteArr.clear();

    selectedDate = DateTime.now();

    selectedTime = const TimeOfDay(hour: 00, minute: 00);

    departureTime = "";

    distanceStr = "";

    distancetxt = "";

    durationtxt = "";

    journeyRoute.clear();

    _selectedRadio = 1;
  }

  customDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: title,
          message: message,
          onPressed: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff09313c),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb0edff)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xff052028),
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
              text: "Dashboard",
              style: TextStyle(
                  fontFamily: 'RRegular',
                  fontSize: 6.sp,
                  color: const Color(0xff6acce9))),
        ),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: isInternet
                    ? const Icon(
                        Icons.signal_wifi_4_bar,
                        color: Color(0xffb0edff),
                        size: 26.0,
                      )
                    : const Icon(
                        Icons.signal_wifi_off,
                        color: Color(0xffb0edff),
                        size: 26.0,
                      ),
              )),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.help,
                  color: Color(0xffb0edff),
                ),
              )),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("CONFIRMATION"),
                      content: const Text("Are You Sure To Logout?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            logoutClear();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text('YES'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('NO'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xffb0edff),
                ),
              )),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 3.5.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.3.w),
            child: RichText(
              text: TextSpan(
                  text: "Create Journey",
                  style: TextStyle(
                      fontFamily: 'RBold',
                      fontSize: 6.sp,
                      color: const Color(0xffbcc0cb))),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomIconRadioButton(
                iconData: FontAwesomeIcons.userCheck,
                selectedColor: const Color(0xff105064),
                unselectedColor: const Color.fromARGB(255, 6, 77, 98),
                isSelected: _selectedRadio == 1,
                onTap: () {
                  setState(() {
                    loadDrivers();
                    _selectedRadio = 1;
                  });
                },
              ),
              CustomIconRadioButton(
                iconData: FontAwesomeIcons.truck,
                selectedColor: const Color(0xff105064),
                unselectedColor: const Color.fromARGB(255, 6, 77, 98),
                isSelected: _selectedRadio == 2,
                onTap: () {
                  setState(() {
                    loadVehicles();
                    _selectedRadio = 2;
                  });
                },
              ),
              CustomIconRadioButton(
                iconData: FontAwesomeIcons.locationCrosshairs,
                selectedColor: const Color(0xff105064),
                unselectedColor: const Color.fromARGB(255, 6, 77, 98),
                isSelected: _selectedRadio == 3,
                onTap: () {
                  setState(() {
                    _selectedRadio = 3;
                  });
                },
              ),
            ],
          ),
          SizedBox(
            height: 9.3.h,
          ),
          if (_selectedRadio == 1) selectDriver(),
          if (_selectedRadio == 2) selectVehicle(),
          if (_selectedRadio == 3) selectLocation(),
        ],
      ),
    );
  }

  Widget selectDriver() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 9.3.w),
          child: RichText(
            text: TextSpan(
              text: "Select Driver",
              style: TextStyle(
                  fontFamily: 'RBold',
                  fontSize: 3.5.sp,
                  color: const Color(0xffbcc0cb)),
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Autocomplete<Driver>(
                initialValue: TextEditingValue(text: _driverName.toString()),
                optionsBuilder: (TextEditingValue texteditingvalue) {
                  return names
                      .where((Driver driver) => driver.name!
                          .toLowerCase()
                          .startsWith(texteditingvalue.text.toLowerCase()))
                      .toList();
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(
                          0xff052028), // Set the background color of the container
                      borderRadius:
                          BorderRadius.circular(50), // Set the corner radius
                    ),
                    child: TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Select a driver',
                        hintStyle: const TextStyle(
                            fontFamily: 'RRegular',
                            fontSize: 16,
                            color: Color(0xffb0edff)),
                        labelStyle: MyTextStyle.smallTitleTextStyle,
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        border: InputBorder.none,
                        suffixIcon: fieldTextEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Color(0xffb0edff), size: 16),
                                onPressed: () {
                                  fieldTextEditingController.clear();
                                })
                            : IconButton(
                                icon: const Icon(Icons.search,
                                    color: Color(0xffb0edff), size: 16),
                                onPressed: () {
                                  loadDrivers();
                                }), // Add padding to the text field
                      ),
                      style: const TextStyle(
                          fontFamily: 'RRegular',
                          fontSize: 16,
                          color: Color(0xffb0edff)),
                    ),
                  );
                  /*TextField(
                    controller: fieldTextEditingController,
                    //focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      hintStyle: MyTextStyle.bigTitleTextStyle,
                      hintText: 'Select a driver',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      labelStyle: MyTextStyle.smallTitleTextStyle,
                      suffixIcon: fieldTextEditingController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Color(0xffb0edff), size: 20),
                              onPressed: () {
                                fieldTextEditingController.clear();
                              })
                          : IconButton(
                              icon: const Icon(Icons.search,
                                  color: Color(0xffb0edff), size: 20),
                              onPressed: () {}),
                    ),
                    style: MyTextStyle.bigTitleTextStyle,
                  );*/
                },
                displayStringForOption: (Driver driver) => driver.name!,
                onSelected: (Driver driver) {
                  setState(() {
                    selectedName = driver;
                    _driverName = driver.name!;
                    _driverID = driver.id!.toString();
                  });
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Driver> onSelected,
                    Iterable<Driver> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        width: 300,
                        color: const Color(0xff105064),
                        child: options.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.all(10.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Driver option =
                                      options.elementAt(index);

                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: ListTile(
                                      title: Text(option.name!,
                                          style: const TextStyle(
                                              fontFamily: 'RRegular',
                                              fontSize: 16,
                                              color: Color(0xffb0edff))),
                                    ),
                                  );
                                },
                              )
                            : const Text("No Drivers Found"),
                      ),
                    ),
                  );
                },
              ),
            ),
            IconButton(
                onPressed: driverFilterPopup,
                icon: const Icon(Icons.filter_list,
                    color: Color(0xffb0edff), size: 20)),
          ],
        ),

        if (selectedName?.compliance == null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 100),
              Center(
                  child: Text("No compliance data",
                      style: TextStyle(
                          fontFamily: 'RRegular',
                          fontSize: 16,
                          color: Color(0xffbcc0cb))))
            ],
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: selectedName?.compliance?.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                    '${index + 1}  ${selectedName!.compliance![index].name.toString()}',
                    style: const TextStyle(
                        fontFamily: 'RRegular',
                        fontSize: 16,
                        color: Color(0xffbcc0cb))),
                trailing:
                    selectedName?.compliance?[index].status.toString() == "0"
                        ? const Icon(FontAwesomeIcons.solidCircleCheck,
                            color: Color(0xffabcb7b))
                        : const Icon(FontAwesomeIcons.solidCircleStop,
                            color: Colors.red),
              );
            },
          ),

        // other widgets
      ],
    );
  }

  Widget selectVehicle() {
    return Container(
      padding: const EdgeInsets.only(left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: const Text(
              "Select Vehicle",
              style: TextStyle(
                  fontFamily: 'RBold', fontSize: 14, color: Color(0xffbcc0cb)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Autocomplete<Vehicle>(
                  initialValue: TextEditingValue(text: _vehicleName),
                  optionsBuilder: (TextEditingValue texteditingvalue) {
                    return vehiclenames
                        .where((Vehicle vehicle) => vehicle.name!
                            .toLowerCase()
                            .startsWith(texteditingvalue.text.toLowerCase()))
                        .toList();
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController vehicleFieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xff052028), // Set the background color of the container
                        borderRadius:
                            BorderRadius.circular(50), // Set the corner radius
                      ),
                      child: TextField(
                        controller: vehicleFieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Select a Vehicle',
                          hintStyle: const TextStyle(
                              fontFamily: 'RRegular',
                              fontSize: 16,
                              color: Color(0xffb0edff)),
                          labelStyle: MyTextStyle.smallTitleTextStyle,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          border: InputBorder.none,
                          suffixIcon: vehicleFieldTextEditingController
                                  .text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Color(0xffb0edff), size: 16),
                                  onPressed: () {
                                    vehicleFieldTextEditingController.clear();
                                  })
                              : IconButton(
                                  icon: const Icon(Icons.search,
                                      color: Color(0xffb0edff), size: 16),
                                  onPressed: () {
                                    loadVehicles();
                                  }), // Add padding to the text field
                        ),
                        style: const TextStyle(
                            fontFamily: 'RRegular',
                            fontSize: 16,
                            color: Color(0xffb0edff)),
                      ),
                    ); /*TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: InputDecoration(
                        hintStyle: MyTextStyle.bigTitleTextStyle,
                        hintText: 'Select a Vehicle',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0)),
                        labelStyle: MyTextStyle.smallTitleTextStyle,
                        suffixIcon: fieldTextEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Color(0xffb0edff), size: 20),
                                onPressed: () {
                                  fieldTextEditingController.clear();
                                })
                            : IconButton(
                                icon: const Icon(Icons.search,
                                    color: Color(0xffb0edff), size: 20),
                                onPressed: () {}),
                      ),
                      style: MyTextStyle.bigTitleTextStyle,
                    );*/
                  },
                  displayStringForOption: (Vehicle vehicle) => vehicle.name!,
                  onSelected: (Vehicle vehicle) {
                    setState(() {
                      selectedVehicle = vehicle;
                      _vehicleName = vehicle.name!;
                      _vehicleID = vehicle.id.toString();
                    });
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<Vehicle> onSelected,
                      Iterable<Vehicle> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: 300,
                          color: const Color(0xff105064),
                          child: options.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.all(10.0),
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Vehicle option =
                                        options.elementAt(index);

                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option.name!,
                                            style: const TextStyle(
                                                fontFamily: 'RRegular',
                                                fontSize: 16,
                                                color: Color(0xffb0edff))),
                                      ),
                                    );
                                  },
                                )
                              : const Text("No Vehicles Found"),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                  onPressed: vehicleFilterPopup,
                  icon: const Icon(Icons.filter_list,
                      color: Color(0xffb0edff), size: 20))
            ],
          ),

          if (selectedVehicle?.compliance == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 100),
                Center(
                    child: Text("No compliance data",
                        style: TextStyle(
                            fontFamily: 'RRegular',
                            fontSize: 16,
                            color: Color(0xffbcc0cb))))
              ],
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: selectedVehicle?.compliance?.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      ' ${index + 1}  ${selectedVehicle!.compliance![index].name.toString()}',
                      style: const TextStyle(
                          fontFamily: 'RRegular',
                          fontSize: 16,
                          color: Color(0xffbcc0cb))),
                  trailing:
                      selectedVehicle?.compliance?[index].status.toString() ==
                              "1"
                          ? const Icon(FontAwesomeIcons.solidCircleCheck,
                              color: Color(0xffabcb7b))
                          : const Icon(FontAwesomeIcons.solidCircleStop,
                              color: Colors.red),
                );
              },
            ),

          // other widgets
        ],
      ),
    );
  }

  Widget selectLocation() {
    return Container(
      padding: const EdgeInsets.only(left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: const Text(
              "Start Location",
              style: TextStyle(
                  fontFamily: 'RBold', fontSize: 14, color: Color(0xffbcc0cb)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(
                      0xff052028), // Set the background color of the container
                  borderRadius:
                      BorderRadius.circular(50), // Set the corner radius
                ),
                child: TextField(
                  controller: _startLocationCtrllor,
                  readOnly: true,
                  onTap: () {
                    _searchLocation("START");
                  },
                  decoration: InputDecoration(
                    hintText: 'Select start location',
                    hintStyle: const TextStyle(
                        fontFamily: 'RRegular',
                        fontSize: 16,
                        color: Color(0xffb0edff)),
                    labelStyle: MyTextStyle.smallTitleTextStyle,
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    border: InputBorder.none,
                    suffixIcon: _startLocationCtrllor.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: Color(0xffb0edff), size: 16),
                            onPressed: () {
                              _startLocationCtrllor.clear();
                            })
                        : IconButton(
                            icon: const Icon(Icons.search,
                                color: Color(0xffb0edff), size: 16),
                            onPressed: () {}), // Add padding to the text field
                  ),
                  style: const TextStyle(
                      fontFamily: 'RRegular',
                      fontSize: 16,
                      color: Color(0xffb0edff)),
                ),
              ),
              /*TextField(
              readOnly: true,
              onTap: () {
                _searchLocation("START");
              },
              controller: _startLocationCtrllor,
              decoration: InputDecoration(
                hintStyle: MyTextStyle.bigTitleTextStyle,
                hintText: 'Start Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                labelStyle: TextStyle(color: _color5),
                suffixIcon: _startLocationCtrllor.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xffb0edff), size: 20),
                        onPressed: () {
                          _startLocationCtrllor.clear();
                        })
                    : IconButton(
                        icon: const Icon(Icons.search,
                            color: Color(0xffb0edff), size: 20),
                        onPressed: () {}),
              ),
              style: MyTextStyle.bigTitleTextStyle,
            )*/
            ),
            IconButton(
                onPressed: () {
                  _selectDate(context);
                },
                icon: const Icon(Icons.more_time,
                    color: Color(0xffb0edff), size: 25)),
          ]),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: Text(
              (departureTimeLbl),
              style: const TextStyle(
                  fontFamily: 'RRegular',
                  fontSize: 12,
                  color: Color(0xffbcc0cb)),
            )),
          ]),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: const Text(
              "End Location",
              style: TextStyle(
                  fontFamily: 'RBold', fontSize: 14, color: Color(0xffbcc0cb)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(
                      0xff052028), // Set the background color of the container
                  borderRadius:
                      BorderRadius.circular(50), // Set the corner radius
                ),
                child: TextField(
                  controller: _endLocationCtrllor,
                  readOnly: true,
                  onTap: () {
                    _searchLocation("END");
                  },
                  decoration: InputDecoration(
                    hintText: 'Select end location',
                    hintStyle: const TextStyle(
                        fontFamily: 'RRegular',
                        fontSize: 16,
                        color: Color(0xffb0edff)),
                    labelStyle: MyTextStyle.smallTitleTextStyle,
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    border: InputBorder.none,
                    suffixIcon: _endLocationCtrllor.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: Color(0xffb0edff), size: 16),
                            onPressed: () {
                              _endLocationCtrllor.clear();
                            })
                        : IconButton(
                            icon: const Icon(Icons.search,
                                color: Color(0xffb0edff), size: 16),
                            onPressed: () {}), // Add padding to the text field
                  ),
                  style: const TextStyle(
                      fontFamily: 'RRegular',
                      fontSize: 16,
                      color: Color(0xffb0edff)),
                ),
              ),
              /*TextField(
              readOnly: true,
              onTap: () {
                _searchLocation("END");
              },
              controller: _endLocationCtrllor,
              decoration: InputDecoration(
                hintStyle: MyTextStyle.bigTitleTextStyle,
                hintText: 'End Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                labelStyle: TextStyle(color: _color5),
                suffixIcon: _endLocationCtrllor.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xffb0edff), size: 20),
                        onPressed: () {
                          _endLocationCtrllor.clear();
                        })
                    : IconButton(
                        icon: const Icon(Icons.search,
                            color: Color(0xffb0edff), size: 20),
                        onPressed: () {}),
              ),
              style: MyTextStyle.bigTitleTextStyle,
            )*/
            ),
            IconButton(
                onPressed: selectRoutes,
                icon: const Icon(Icons.add_location,
                    color: Color(0xffb0edff), size: 25))
          ]),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: Text(
              ('$durationtxt $distancetxt'),
              style: const TextStyle(
                  fontFamily: 'RBold', fontSize: 16, color: AppColors.color4c4),
            )),
          ]),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                          Color(0xFF0f5164)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                    onPressed: () {
                      journeyClear();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        /*Icon(
                          FontAwesomeIcons.solidCircleCheck,
                          size: 30,
                          color: Color(0xFFb0edff),
                          // color: HexColor("#6acce9"),
                        ),*/
                        Text("Clear",
                            style: TextStyle(
                                fontFamily: "RBold",
                                fontSize: 16,
                                color: Color(0xFFb0edff))),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                          Color(0xFF0f5164)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                    onPressed: () {
                      journeyConfirm();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        /* Icon(
                          FontAwesomeIcons.solidCircleXmark,
                          size: 30,
                          color: Color(0xFFb0edff),
                        ),*/
                        Text("Confirm",
                            style: TextStyle(
                                fontFamily: "RBold",
                                fontSize: 16,
                                color: Color(0xFFb0edff))),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          /*Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF1d424e), // background
                onPrimary: Color(0xffb0edff),
                textStyle: MyTextStyle.smallHeadingTextStyle, // foreground
              ),
              onPressed: () {
                journeyClear();
              },
              child: const Text(
                "Clear",
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1d424e), // background
                  onPrimary: Color(0xffb0edff),
                  textStyle: MyTextStyle.smallHeadingTextStyle // foreground
                  ),
              onPressed: () {
                journeyConfirm();
              },
              child: const Text(
                "Confirm",
              ),
            ),
          ]),*/
        ],
      ),
    );
  }
}
