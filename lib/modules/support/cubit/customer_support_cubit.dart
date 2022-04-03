import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_of_egypt_client/shared/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/constants.dart';
import 'customer_support_states.dart';

class CustomerSupportCubit extends Cubit<CustomerSupportStates> {
  CustomerSupportCubit() : super(CustomerSupportInitialState());

  static CustomerSupportCubit get(context) => BlocProvider.of(context);


  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("UserType") == null) {
      customerLogged = false;
      customerState.value = 0;
      emit(CustomerSupportChangeUserLoggedState());
    } else {
      if (prefs.getString("UserType") == "Customer") {

        customerLogged = true;
        customerState.value = 1;
        emit(CustomerSupportChangeUserLoggedState());
      }else{
        customerLogged = false;
        customerState.value = 0;
        emit(CustomerSupportChangeUserLoggedState());
      }
    }
  }
  void navigate(BuildContext context, route){
    navigateTo(context, route);
  }
}
