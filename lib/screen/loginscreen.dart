import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/data/provider/login_provider.dart';
import 'package:tracer/themes/app_colors.dart';
import 'package:tracer/widget/mytextstyle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;
  final Color _color5 = const Color(0xFFFFFFFF);
  final Color _color1 = const Color(0xFFDC1C13);

  @override
  void initState() {
    super.initState();
    //Journey Manager Login Details
    // emailController.text = "gulfps_admin";
    // passwordController.text = "gulf123";

    // Driver Login Details
    // emailController.text = "naserSah";
    // passwordController.text = "nase5283";
    emailController.text = "ashokKumar";
    passwordController.text = "asho7671";
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xff09313c),
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light),
        child: Padding(
          padding: EdgeInsets.only(left: 7.5.w, right: 7.5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 19.h,
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 20.w,
                  height: 28.8.h,
                ),
              ),
              SizedBox(
                height: 3.7.h,
              ),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Login",
                    style: TextStyle(
                        fontFamily: 'RRegular',
                        fontSize: 8.5.sp,
                        color: AppColors.color4c4),
                  ),
                ),
              ),
              SizedBox(height: 11.3.h),
              RichText(
                text: TextSpan(
                  text: "Username",
                  style: TextStyle(
                      fontFamily: 'RMedium',
                      fontSize: 3.5.sp,
                      color: AppColors.color4c4),
                ),
              ),
              TextFormField(
                controller: emailController,
                style: MyTextStyle.smallTitleTextStyle
                    .copyWith(fontSize: 3.5.sp, fontFamily: "RMedium"),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0f5164)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0f5164)),
                    ),
                    hintText: "Username",
                    suffixIcon: Icon(Icons.check,
                        size: 4.6.sp, color: AppColors.color4c4),
                    labelStyle: TextStyle(color: _color5)),
              ),
              SizedBox(
                height: 3.8.h,
              ),
              RichText(
                text: TextSpan(
                  text: "Password",
                  style: TextStyle(
                      fontFamily: 'RMedium',
                      fontSize: 3.5.sp,
                      color: AppColors.color4c4),
                ),
              ),
              TextFormField(
                controller: passwordController,
                style: MyTextStyle.smallTitleTextStyle,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "Password",
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0f5164)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0f5164)),
                  ),
                  labelStyle: TextStyle(color: _color5),
                  suffixIcon: IconButton(
                      icon: Icon(_iconVisible,
                          color: AppColors.colordff, size: 20),
                      onPressed: () {
                        _toggleObscureText();
                      }),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: SizedBox(
                  height: 7.5.h,
                  width: 20.5.w,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                          Color(0xFF0f5164)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(3.8.sp)),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: 'Please enter the valid username',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT);
                        _btnController.error();
                      } else if (passwordController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: 'Please enter the Password',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT);
                        _btnController.error();
                      } else {
                        final DeviceInfoPlugin deviceInfoPlugin =
                            DeviceInfoPlugin();

                        var deviceData = authProvider.readAndroidBuildData(
                            await deviceInfoPlugin.androidInfo);
                        authProvider.setDeviceData(deviceData);
                        var result = await authProvider.loginAPI(
                            emailController.text, passwordController.text);
                        if (result.s == 0) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          prefs.setString('username', result.p!.username!);
                          prefs.setString('token', result.p!.token!);
                          prefs.setString('userid', result.p!.userid!);
                          prefs.setString('usertype', result.p!.usertype!);
                          prefs.setString('status', "1");
                          if (result.p!.usertype! == "1") {
                            Fluttertoast.showToast(
                                msg: "${result.p!.message}",
                                gravity: ToastGravity.CENTER,
                                toastLength: Toast.LENGTH_LONG);
                            if (context.mounted) {
                              Navigator.pushNamed(context, '/homescreen');
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pushNamed(context, '/driverscreen');
                            }
                          }
                        } else {
                          Fluttertoast.showToast(msg: result.p!.message!);
                        }
                      }
                    },
                    child: authProvider.isLoading == false
                        ? RichText(
                            text: TextSpan(
                                text: "Login",
                                style: MyTextStyle.smallTitleTextStyle.copyWith(
                                    fontSize: 3.5.sp,
                                    fontFamily: 'RMedium',
                                    color: AppColors.colordff)),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// need to remvove at production
class HandleResponse {
  static handleRes(response) {
    Map<String, dynamic>? resJson;
    if (response is String) {
      return resJson = json.decode(response);
    } else if (response is Map<String, dynamic>) {
      return resJson = response;
    } else {
      print("Invaild Query");
      // throw DioError(message: 'Data parsing error');
    }
  }
}
