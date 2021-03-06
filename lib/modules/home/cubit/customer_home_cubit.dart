import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../Posts/screens/global_display_posts_screen.dart';
import '../../questions/screens/customer_questions_screen.dart';
import '../../settings/screens/customer_settings_screen.dart';
import '../../chat/screens/display_chats_screen.dart';
import 'customer_home_states.dart';

class CustomerHomeCubit extends Cubit<CustomerHomeStates>{

  CustomerHomeCubit() : super(CustomerHomeInitialState());

  static CustomerHomeCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<BottomNavigationBarItem> bottomNavigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(
        IconlyBroken.discovery,
      ),
      label: 'اخبار المشروع',
    ),
    const BottomNavigationBarItem(
      icon: Icon(
        IconlyBroken.category,
      ),
      label: 'الاستفسارات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(
        IconlyBroken.chat,
      ),
      label: 'الدعم',
    ),
    const BottomNavigationBarItem(
      icon: Icon(
        IconlyBroken.setting,
      ),
      label: 'الاعدادات',
    ),
  ];

  List<Widget> screens = [
    GlobalDisplayPostsScreen(),
    CustomerQuestionsScreen(),
    CustomerSupportScreen(),
    CustomerSettingsScreen(),
  ];

  void changeBottomNavBarIndex(int index, BuildContext context) async {
    currentIndex = index;

    emit(CustomerHomeChangeBottomNavState());
  }

}