import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition_plus/transition_plus.dart';

import '../../../models/display_chat_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/components.dart';
import '../../../shared/constants.dart';
import 'display_chats_states.dart';

class CustomerDisplayChatsCubit extends Cubit<CustomerDisplayChatsStates> {

  CustomerDisplayChatsCubit() : super(CustomerDisplayChatsInitialState());

  static CustomerDisplayChatsCubit get(context) => BlocProvider.of(context);

  DisplayChatModel? displayChatModel;
  UserModel? userModel;

  List<UserModel> userList = [];
  List<DisplayChatModel> chatList = [];
  String? userImage;

  Future<void> getMyData()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userImage = prefs.getString("CustomerImageUrl")!;
    emit(CustomerDisplayChatsGetMyDataState());
  }
  void goToConversation(BuildContext context, route) {
    Navigator.push(context, ScaleTransition1(page: route, startDuration: const Duration(milliseconds: 800),closeDuration: const Duration(milliseconds: 500), type: ScaleTrasitionTypes.bottomRight));
    //navigateTo(context, route);
  }

  Future<void> getChats() async {
    await getMyData();
    emit(CustomerDisplayChatsLoadingChatsState());

    SharedPreferences prefs = await SharedPreferences.getInstance();
      print("IDDDDDD : ${prefs.getString("CustomerID")}\n");

      await FirebaseDatabase.instance
          .reference()
          .child('ChatList')
          .child(prefs.getString("CustomerID")!)
          .once()
          .then((snapshot){
        Map<dynamic, dynamic> values = snapshot.value;
        chatList.clear();
        values.forEach((key,user){
          displayChatModel = DisplayChatModel(user["ReceiverID"]);
          chatList.add(displayChatModel!);
        });
      });

      await FirebaseDatabase.instance
          .reference()
          .child('Clients')
          .once()
          .then((snapshot){
        Map<dynamic, dynamic> values = snapshot.value;

        userList.clear();
        values.forEach((key,user){

          userModel = UserModel(user["ClientID"],user["ClientName"],user["ClientPhone"],user["ClientPassword"],user["ClientCity"],user["ClientRegion"],user["ClientDocType"],user["ClientDocNumber"],user["ClientImage"],user["ClientToken"],user["ClientLastMessage"],user["ClientState"],user["ClientLastMessageTime"]);

          for (var list in chatList) {
            print("Chat List Length For Loop : ${chatList.length}\n");

            if (userModel!.userID == list.userID) {
              userList.add(userModel!);
            }
          }
          print("Chat List Length : ${chatList.length}\n");
          print("Chat List Length : ${userList.length}\n");
          emit(CustomerDisplayChatsGetChatsState());
        });
      });
  }
}