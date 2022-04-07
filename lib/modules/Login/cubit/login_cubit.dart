import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/remote/dio_helper.dart';
import '../../../shared/components.dart';
import '../../home/layout/customer_home_layout.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  double? classificationPersonID;
  IconData suffix = Icons.visibility_rounded;

  void changePasswordVisibility() {
    isPassword = !isPassword;

    suffix =
        isPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded;

    emit(LoginChangePassVisibility());
  }

  void signInUser(String userName, String userPassword) async {
    emit(LoginLoadingSignIn());

    var connectivityResult = await (Connectivity().checkConnectivity());

    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.none)) {
      showToast(
        message: "برجاءالاتصال بشبكة المشروع اولاً",
        length: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
      );
      emit(LoginNoInternetState());
    } else if (connectivityResult == ConnectivityResult.wifi) {
      final info = NetworkInfo();

      info.getWifiIP().then((deviceIP) async {
        if (deviceIP!.contains("172.16.1.") || deviceIP.contains("١٧٢")) {
          await DioHelper.getData(
                  url: 'login/GetWithParams',
                  query: {'User_Name': userName, 'User_Password': userPassword})
              .then((value) async {
            print(value.statusMessage.toString());

            if (value.statusMessage == "No User Found") {
              showToast(
                  message: "لا يوجد مستخدم بهذه البيانات",
                  length: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3);

              emit(LoginNoUserState());
            } else {
              classificationPersonID =
                  value.data[0]["Classification_Persons_ID"];

              await getClientFirebase(classificationPersonID!.round().toString());
            }
          }).catchError((error) {
            if (error.type == DioErrorType.response) {
              showToast(
                  message: "لا يوجد مستخدم بهذه البيانات",
                  length: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3);

              emit(LoginNoUserState());
            } else {
              emit(LoginErrorState(error.toString()));
            }
          });
        } else {
          showToast(
              message: "برجاء الاتصال بشبكة المشروع اولاً",
              length: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3);
          emit(LoginNoInternetState());
        }
      });
    }
  }

  Future<void> getClientFirebase(String clientID) async {
    await FirebaseDatabase.instance
        .reference()
        .child("Clients")
        .child(clientID)
        .once()
        .then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      print("DATAAA : ${value.value["ClientName"]}\n");
      print("DATAAA : ${value.value["ClientID"]}\n");
      print("DATAAA : ${value.value["ClientDocNumber"]}\n");

      await prefs.setString("CustomerID", value.value["ClientID"].toString());
      await prefs.setString("CustomerName", value.value["ClientName"].toString());
      await prefs.setString("CustomerPhone", value.value["ClientPhone"].toString());
      await prefs.setString("CustomerPassword", value.value["ClientPassword"].toString());
      await prefs.setString(
          "CustomerDocType", value.value["ClientDocType"].toString());
      await prefs.setString(
          "CustomerDocNumber", value.value["ClientDocNumber"].toString());
      await prefs.setString(
          "CustomerCity", value.value["ClientCity"].toString());
      await prefs.setString(
          "CustomerRegion", value.value["ClientRegion"].toString());
      await prefs.setString(
          "CustomerImageUrl", value.value["ClientImage"].toString());
      await prefs.setString(
          "CustomerToken", value.value["ClientToken"].toString());

      var token = await FirebaseMessaging.instance.getToken();
      await FirebaseDatabase.instance.reference().child("Clients").child(clientID).child("ClientToken").set(token);
      await prefs.setString("CustomerToken", token!);

      emit(LoginGetClientDataSuccessState());
    }).catchError((error) {
      emit(LoginGetClientDataErrorState(error.toString()));
    });
  }

  void backToPosts(BuildContext context) {
    navigateAndFinish(context, CustomerHomeLayout());
  }

  var connectivityResult = (Connectivity().checkConnectivity());
  bool hasInternet = false;

  Future<void> checkConnection() async {
    Future<bool> noConnection = noInternetConnection();

    noConnection.then((value) {
      hasInternet = value;
      if (value == true) {
        emit(LoginNoInternetState());
      }
    });
  }
}
