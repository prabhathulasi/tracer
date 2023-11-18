import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/common/api.dart';
import 'package:tracer/data/model/vehicleinspectionmodel.dart';
import 'package:tracer/data/provider/inspection_provider.dart';
import 'package:tracer/screen/account_screen.dart';
import 'package:tracer/screen/imagepreviewscreen.dart';
import 'package:tracer/screen/loginscreen.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/app_richtext.dart';
import 'package:tracer/widget/inspectionlistitem.dart';
import 'package:tracer/widget/mytextstyle.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class DriverVehicleInspectionScreenPage extends StatefulWidget {
  final String journeyID;

  //final List<CameraDescription>? cameras;
  const DriverVehicleInspectionScreenPage({
    super.key,
    required this.journeyID,
  });

  @override
  _DriverVehicleInspectionScreenPageState createState() =>
      _DriverVehicleInspectionScreenPageState();
}

class _DriverVehicleInspectionScreenPageState
    extends State<DriverVehicleInspectionScreenPage> {
  String? token;
  late Response response;
  late InspectionPayload ipModel;

  List<VehicleInspectionModel> viList = [];

  dynamic _pickImageError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    ipModel = InspectionPayload();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getSharedPrefenceVal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedPrefenceVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    fetchImageData();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    log('Connection Status: $result');
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  formatDate(String dateTime) {
    // DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
    //   startepoc,
    // );

    String startDateString =
        DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(dateTime));

    String resultime = startDateString;

    return resultime;
  }

  int? uploadedImagesLength;
  fetchImageData() async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "5"});

    data.addAll({'p[journey_id]': widget.journeyID});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    log(response.data.toString());

    //Map<String, dynamic> json = jsonDecode(response.data.toString());
    //VehicleInspectionModel viModel = VehicleInspectionModel.fromJson(json);

    //print(djModel.p.message);

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      Map<String, dynamic> jsonMap =
          (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
      Map<String, dynamic> jsonList = jsonMap['p'] as Map<String, dynamic>;

      setState(() {
        ipModel = InspectionPayload.fromJson(jsonList);
        // uploadedImagesLength = jsonList["img_arr"].length;
        /*
        DriverJourney djouyModel = new DriverJourney();
        djouyModel.type = 0;
        djouyModel.loc = "Vehicle Inspection";
        djList.add(djouyModel);
        djList.addAll(djModel.pointsArr);
        */
      });
      if (jsonList.containsKey('img_arr')) {
        uploadedImagesLength = jsonList['img_arr'].length;
      }

      //print(djModel.pointsArr);
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text("Failed to Load. Please try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    progress?.dismiss();
  }

  logoutClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("status", "0");
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      int len = 0;
      if (ipModel.pointsArr.isEmpty) {
        len = 0;
      } else {
        len = ipModel.pointsArr.length;
      }
      setState(() {
        ImageData imModel = ImageData();
        imModel.sno = len + 1;
        imModel.imageUploaded = false;
        imModel.alreadyUploaded = false;
        imModel.path = pickedFile!.path.toString();
        imModel.datetime = DateTime.now().toString();
        ipModel.pointsArr.add(imModel);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> _uploadImage(File image, int index) async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_driver";

    final fileName = path.basename(image.path);
    final formData = FormData.fromMap({
      'c': '3',
      'p[journey_id]': widget.journeyID,
      'image': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";
      response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        var dataVal =
            (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

        if (dataVal['s'] == 0) {
          Map<String, dynamic> jsonMap =
              (HandleResponse.handleRes(response.data) as Map<String, dynamic>);
          Map<String, dynamic> jsonList = jsonMap['p'] as Map<String, dynamic>;
          await fetchImageData();
          setState(() {
            ipModel.pointsArr[index].id =
                int.parse(jsonList['image_id'].toString());
            ipModel.pointsArr[index].imageUploaded = true;
            ipModel.pointsArr[index].alreadyUploaded = true;
          });
          // SharedPreferences prefs = await SharedPreferences.getInstance();

          // prefs.setInt('inspectiondone', 1);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image uploaded successfully'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Failed to upload image. Please retry after some time'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to upload image. Please retry after some time'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload image. Please retry after some time'),
        backgroundColor: Colors.red,
      ));
    }
    progress?.dismiss();
  }

  void deleteImage(int imageID, int index) async {
    final progress = ProgressHUD.of(context);
    progress?.show();
    String url = TracerApis.login + "?controller=jm_driver";

    Map<String, dynamic> data = {};
    data.addAll({'c': "4"});

    data.addAll({'p[journey_id]': widget.journeyID});
    data.addAll({'p[image_id]': imageID});

    var dio = Dio();
    dio.options.headers["Authorization"] = "Bearer $token";
    response = await dio.post(url, queryParameters: data);
    print(response.data.toString());

    var dataVal =
        (HandleResponse.handleRes(response.data) as Map<String, dynamic>);

    if (dataVal['s'] == 0) {
      log(dataVal.toString());
      setState(() {
        ipModel.pointsArr.removeAt(index);
        uploadedImagesLength = ipModel.pointsArr.length;
      });
      log(ipModel.pointsArr.length.toString());

      //print(djModel.pointsArr);
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text("Failed to Load. Please try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    progress?.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleInspectionProvider = Provider.of<InspectionProvider>(context);

    return Scaffold(
        backgroundColor: const Color(0xff09313c),
        appBar: AppBar(
          leadingWidth: 7.w,
          iconTheme: const IconThemeData(color: AppColors.colordff),
          backgroundColor: Colors.transparent,
          title: Text("Vehicle Inspection",
              style: TextStyle(
                  fontFamily: 'RRegular',
                  fontSize: 6.sp,
                  color: const Color(0xffb0edff))),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {},
                    child: _connectionStatus == ConnectivityResult.wifi ||
                            _connectionStatus == ConnectivityResult.mobile
                        ? Container()
                        : Image.asset(
                            "assets/images/no_wifi.png",
                            width: 5.8.w,
                          ))),
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.help, color: Color(0xffb0edff)),
                )),
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.account_circle,
                    color: Color(0xffb0edff),
                  ),
                )),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(children: [
            Column(
              children: [
                SizedBox(height: 6.3.h),
                Text(
                  'Upload Vehicle Images',
                  style: TextStyle(
                      fontFamily: "RRegular",
                      fontSize: 5.sp,
                      color: AppColors.color4c4),
                ),
              ],
            ),
            SizedBox(height: 5.5.h),
            Container(
              height: 100.h,
              width: 86.3.w,
              color: const Color(0xff0f5164),
              child: (ipModel.pointsArr.isNotEmpty)
                  ? ListView.builder(
                      itemCount: ipModel.pointsArr.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = ipModel.pointsArr[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InspectionListItem(
                              indexLabel: (index + 1).toString(),
                              imagePath: item.path,
                              alreadyUploaded: item.alreadyUploaded!,
                              imgUploaded: item.imageUploaded!,
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagePreviewScreen(
                                        image: item.path,
                                        webImage: item.alreadyUploaded),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteImage(item.id, index);
                              },
                              onUploadPressed: () async {
                                await _uploadImage(File(item.path), index);
                              },
                            ),
                            SizedBox(height: 1.3.h),
                            Padding(
                              padding: EdgeInsets.only(left: 7.w),
                              child: Text(
                                formatDate(item.datetime!),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: "RRegular",
                                    fontSize: 3.sp,
                                    color: AppColors.color4c4),
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No Records Found",
                        style: MyTextStyle.bigTitleTextStyle,
                      ),
                    ),
            ),
            SizedBox(height: 5.8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _onImageButtonPressed(ImageSource.camera, context: context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff0f5164)),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffb0edff)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0.sp),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/add_image.png",
                        width: 5.w,
                      ),
                      SizedBox(
                          width: 2.5
                              .sp), // Add some space between the icon and the text

                      AppRichText(
                          text: "Capture",
                          style: TextStyle(
                              fontFamily: "RBold",
                              fontSize: 4.sp,
                              color: AppColors.colordff))
                    ],
                  ),
                ),
                SizedBox(
                  width: 10.3.w,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (ipModel.pointsArr.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please Upload the Vehicle Inspection Images!");
                    } else if (ipModel.pointsArr.length ==
                        uploadedImagesLength) {
                      var data = await vehicleInspectionProvider
                          .completeVehicleInspection(
                              int.parse(widget.journeyID));
                      if (data["status"] == 2 && context.mounted) {
                        Navigator.pop(context);
                      }
                      if (data["status"] == 0) {
                        Fluttertoast.showToast(msg: data["status_str"]);
                      }
                    } else {
                      log(ipModel.pointsArr.length.toString());
                      Fluttertoast.showToast(
                          msg: "Please Upload the Vehicle Inspection Images");
                    }
                    // else {
                    //   bool allItemsUploaded = ipModel.pointsArr
                    //       .every((item) => item.imageUploaded == true);
                    //   if (allItemsUploaded == true) {
                    //     var data = await vehicleInspectionProvider
                    //         .completeVehicleInspection(
                    //             int.parse(widget.journeyID));
                    //     if (data["status"] == 2 && context.mounted) {
                    //       Navigator.pop(context);
                    //     }
                    //     if (data["status"] == 0) {
                    //       Fluttertoast.showToast(msg: data["status_str"]);
                    //     }
                    //   } else {
                    //     log(ipModel.pointsArr.length.toString());
                    //     Fluttertoast.showToast(
                    //         msg: "Please Upload the Inspection Images");
                    //   }
                    // }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff0f5164)),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffb0edff)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.solidCircleCheck,
                          size: 5.sp), // Add the icon here
                      SizedBox(
                          width: 2.5
                              .w), // Add some space between the icon and the text

                      AppRichText(
                        text: "Done",
                        style: TextStyle(
                            fontFamily: "RBold",
                            fontSize: 4.sp,
                            color: AppColors.colordff),
                      )
                    ],
                  ),
                ),
              ],
            )
          ]),
        ));
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
