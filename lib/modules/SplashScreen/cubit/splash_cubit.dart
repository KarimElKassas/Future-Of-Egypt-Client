import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_of_egypt_client/modules/Login/login_screen.dart';
import 'package:future_of_egypt_client/modules/SplashScreen/cubit/splash_states.dart';
import 'package:future_of_egypt_client/modules/home/layout/customer_home_layout.dart';
import 'package:future_of_egypt_client/shared/components.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition_plus/transition_plus.dart';

class SplashCubit extends Cubit<SplashStates> {
  SplashCubit() : super(SplashInitialState());

  static SplashCubit get(context) => BlocProvider.of(context);

  double? loginLogID;

  Future<void> navigate(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 4000), () {});

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('CustomerID') == null){
      Navigator.pushReplacement(context, ScaleTransition1(page: LoginScreen(), startDuration: const Duration(milliseconds: 1500),closeDuration: const Duration(milliseconds: 800), type: ScaleTrasitionTypes.bottomRight));
      //navigateAndFinish(context, LoginScreen());
      emit(SplashSuccessNavigateState());
    }else{
      Navigator.pushReplacement(context, ScaleTransition1(page: CustomerHomeLayout(), startDuration: const Duration(milliseconds: 1500),closeDuration: const Duration(milliseconds: 800), type: ScaleTrasitionTypes.bottomRight));
      //navigateAndFinish(context, CustomerHomeLayout());
      emit(SplashSuccessNavigateState());
    }

  }

  Future<void> createMediaFolder() async {

    await FirebaseMessaging.instance.subscribeToTopic("2022-02-20-22-26-32");

    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      var externalDoc = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      final Directory mediaDirectory =
          Directory('$externalDoc/Future Of Egypt Media Client/');

      if (mediaDirectory.existsSync()) {
        emit(SplashSuccessCreateDirectoryState());
      } else {
        await mediaDirectory.create(recursive: true);
        emit(SplashSuccessCreateDirectoryState());
      }

      final Directory documentsDirectory = Directory('/storage/emulated/0/Download/Future Of Egypt Media Client/Documents/');

      if (documentsDirectory.existsSync()) {
        emit(SplashSuccessCreateDirectoryState());
      } else {
        await documentsDirectory.create(recursive: true);
        emit(SplashSuccessCreateDirectoryState());
      }

      final Directory recordingsDirectory = Directory('/storage/emulated/0/Download/Future Of Egypt Media Client/Records/');

      if (recordingsDirectory.existsSync()) {
        emit(SplashSuccessCreateDirectoryState());
      } else {
        await recordingsDirectory.create(recursive: true);
        emit(SplashSuccessCreateDirectoryState());
      }

      final Directory imagesDirectory = Directory('/storage/emulated/0/Download/Future Of Egypt Media Client/Images/');

      if (await imagesDirectory.exists()) {
        emit(SplashSuccessCreateDirectoryState());
      } else {
        await imagesDirectory.create(recursive: true);
        emit(SplashSuccessCreateDirectoryState());
      }
    } else {
      emit(SplashSuccessPermissionDeniedState());
    }
  }

}
