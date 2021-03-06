import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../models/posts_model.dart';
import '../../../network/remote/dio_helper.dart';
import '../../../shared/components.dart';
import 'global_display_posts_states.dart';

class GlobalDisplayPostsCubit extends Cubit<GlobalDisplayPostsStates> {
  GlobalDisplayPostsCubit() : super(GlobalDisplayPostsInitialState());

  static GlobalDisplayPostsCubit get(context) => BlocProvider.of(context);

  YoutubePlayerController? controller;
  double? loginLogID;

  Future initializeVideo(String videoID) async {
    controller = YoutubePlayerController(
      initialVideoId: videoID,
      flags: const YoutubePlayerFlags(
          autoPlay: false, mute: false, hideControls: false),
    );
  }

  Future initializeVideoWithoutPlay(String videoID) async {
    controller = YoutubePlayerController(
      initialVideoId: videoID,
      flags: const YoutubePlayerFlags(
          autoPlay: false, mute: false, hideControls: false),
    );
  }

  PostsModel? postsModel;
  List<PostsModel> postsList = [];
  List<PostsModel> postsListReversed = [];

  void getPosts() async {
    emit(GlobalDisplayPostsLoadingState());

    List<Object?>? postImages = [];

    FirebaseDatabase.instance
        .reference()
        .child('Posts')
        .orderByChild("PostDate")
        .once()
        .then((snapshot) async {
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          String postID = values["PostID"].toString();
          String postTitle = values["PostTitle"].toString();
          String postVideoID = values["PostVideoID"].toString();
          String postDate = values["PostDate"].toString();
          String realDate = values["realDate"].toString();
          String hasImages = values["hasImages"].toString();

          if (values["hasImages"] == "true") {
            postImages = values["PostImages"];
          }

          postsModel = PostsModel(
              postID, postTitle, postVideoID, postDate, hasImages, postImages,realDate);
          postsList.add(postsModel!);
          postsListReversed = postsList.reversed.toList();
        });
      }

      emit(GlobalDisplayPostsSuccessState());
    }).catchError((error) {
      emit(GlobalDisplayPostsErrorState(error.toString()));
    });
  }

  void goToDetails(BuildContext context, route) {
    navigateTo(context, route);
  }

  Future<void> logOut(BuildContext context, SharedPreferences prefs) async {

    loginLogID = prefs.getDouble("Login_Log_ID");
    print("Login Log ID $loginLogID");

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(now);

    await DioHelper.updateData(url: 'loginlog/PutWithParams', query: {
      'Login_Log_ID': loginLogID!.toInt(),
      'Login_Log_TDate': formattedDate,
    }).then((value) {
      prefs.remove("Login_Log_ID");
      prefs.remove("LoginDate");
      prefs.remove("Section_User_ID");
      prefs.remove("Section_ID");
      prefs.remove("Section_Name");
      prefs.remove("Section_Forms_Name_List");
      prefs.remove("User_ID");
      prefs.remove("User_Name");
      prefs.remove("User_Password");

      emit(GlobalDisplayPostsLogOutSuccessState());
    }).catchError((error) {

      if(error is DioError){
        emit(GlobalDisplayPostsLogOutErrorState("?????? ?????? ?????? ???? ?????????? ???????????????? ????????????"));
      }else{
        emit(GlobalDisplayPostsLogOutErrorState(error.toString()));
      }

    });
  }


/*
  void goToLogin(BuildContext context, route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var connectivityResult = await (Connectivity().checkConnectivity());

    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.none)) {
      showToast(
        message: "???????????????????????? ?????????? ?????????????? ??????????",
        length: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
      );
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (prefs.containsKey("LoginDate")) {
        DateTime currentDate = DateTime.now();

        String loginDate = prefs.getString("LoginDate").toString();
        String sectionName = prefs.getString("Section_Name").toString();

        double difference = currentDate
            .difference(DateTime.parse(loginDate))
            .inHours
            .toDouble();
        print("Difference : $difference");

        final info = NetworkInfo();
        info.getWifiIP().then((value) async {
          if (value!.contains("172.16.1.") || value.contains("??????")) {
            print("Mobile Is in The Network \n");

            if (difference >= 24.0) {
              await logOut(context, prefs);
              navigateAndFinish(context, LoginScreen());
              emit(GlobalDisplayPostsNavigateSuccessState());
            } else {
              switch (sectionName) {
                case "?????????? ??????????????":
                  navigateAndFinish(context, SocialHomeLayout());
                  emit(GlobalDisplayPostsNavigateSuccessState());
                  break;
                case "?????????????? ????????????????":
                  navigateAndFinish(context, MechanHomeLayout());
                  emit(GlobalDisplayPostsNavigateSuccessState());
                  break;
                case "?????????? ??????????????":
                  navigateAndFinish(context, ITHomeScreen());
                  emit(GlobalDisplayPostsNavigateSuccessState());
                  break;
              }
            }
          } else {
            showToast(
              message: "???????????????????????? ?????????? ?????????????? ???????? ??????????",
              length: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
            );
          }
        }).catchError((error) {
          showToast(
            message: "?????? ?????? ?????? ????",
            length: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        });
      } else {
        final info = NetworkInfo();
        info.getWifiIP().then((value) async {
          if (value!.contains("172.16.1.") || value.contains("??????")) {
            print("Mobile Is in The Network \n");

            navigateAndFinish(context, LoginScreen());
            emit(GlobalDisplayPostsNavigateSuccessState());
          } else {
            showToast(
              message: "???????????????????????? ?????????? ?????????????? ??????????",
              length: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
            );
          }
        }).catchError((error) {
          showToast(
            message: "?????? ?????? ?????? ????",
            length: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        });
        */
/*navigateAndFinish(context, LoginScreen());
        emit(GlobalDisplayPostsNavigateSuccessState());*//*

      }
    }
  }
*/
}
