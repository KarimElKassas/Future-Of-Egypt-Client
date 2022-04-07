import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_of_egypt_client/modules/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/components.dart';
import '../../../shared/constants.dart';
import 'customer_settings_states.dart';


class CustomerSettingsCubit extends Cubit<CustomerSettingsStates> {
  CustomerSettingsCubit() : super(CustomerSettingsInitialState());

  static CustomerSettingsCubit get(context) => BlocProvider.of(context);

  double downloadSpeed = 0.0;

  void logOutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("CustomerID");
    await prefs.remove("CustomerName");
    await prefs.remove("CustomerRegion");
    await prefs.remove("CustomerCity");
    await prefs.remove("CustomerPhone");
    await prefs.remove("CustomerPassword");
    await prefs.remove("CustomerToken");
    await prefs.remove("CustomerImageUrl");
    await prefs.remove("CustomerDocType");
    await prefs.remove("CustomerDocNumber");

    customerLogged = false;
    customerState.value = 0;

    navigateAndFinish(context, LoginScreen());

    showToast(message: "تم تسجيل الخروج بنجاح",
        length: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3);
    emit(CustomerSettingsLogOutSuccessState());
  }
}
