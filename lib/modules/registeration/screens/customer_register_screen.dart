import 'dart:io' as i;
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:buildcondition/buildcondition.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../shared/components.dart';
import '../../../shared/dropdown/select_drop_list.dart';
import '../cubit/customer_register_cubit.dart';
import '../cubit/customer_register_states.dart';

class CustomerRegisterScreen extends StatelessWidget {
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var nationalIDController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  int? docType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerRegisterCubit()..getCities(),
      child: BlocConsumer<CustomerRegisterCubit, CustomerRegisterStates>(
          listener: (context, state) {
        if (state is CustomerRegisterErrorState) {
          showToast(
            message: state.error,
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        } else if (state is CustomerRegisterGetRegionsErrorState) {
          showToast(
            message: state.error,
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        } else if (state is CustomerRegisterAddNameErrorState) {
          showToast(
            message: state.error,
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        } else if (state
            is CustomerRegisterAddClassificationPersonIDErrorState) {
          showToast(
            message: state.error,
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        } else if (state is CustomerRegisterAddLoginDataErrorState) {
          showToast(
            message: state.error,
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        } else if (state is CustomerRegisterUserExistState) {
          showToast(
            message: "هذا الرقم القومى مسجل من قبل",
            length: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
          );
        }
      },
          builder: (context, state) {
        var cubit = CustomerRegisterCubit.get(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: WillPopScope(
            onWillPop: () {
              if (cubit.cityBottomSheetController != null) {
                cubit.closeCityBottomSheet();
              } else if (cubit.regionBottomSheetController != null) {
                cubit.closeRegionBottomSheet();
              } else {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  SystemNavigator.pop();
                }
              }
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.teal[700],
                  statusBarIconBrightness: Brightness.light,
                  // For Android (dark icons)
                  statusBarBrightness: Brightness.dark, // For iOS (dark icons)
                ),
                elevation: 0,
                backgroundColor: Colors.teal[700],
                title: const Text("إنشاء حساب", style: TextStyle(color: Colors.white, wordSpacing: 1.5),),
              ),
                key: cubit.scaffoldKey,
                body: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12.0, bottom: 12.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: (){
                                  cubit.selectImage();
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  clipBehavior: Clip.none ,
                                  children: [
                                    SizedBox(
                                      width: 160,
                                      height: 160,
                                      child: CircleAvatar(
                                        radius: 160,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(90),
                                          child: BuildCondition(
                                            condition: cubit.emptyImage == true,
                                            builder: (context) => CircleAvatar(
                                              child: const Icon(
                                                Icons.add_photo_alternate,
                                                color: Colors.white,
                                                size: 76,
                                              ),
                                              backgroundColor: Colors.teal.shade700,
                                              maxRadius: 160,
                                            ),
                                            fallback: (context) => SizedBox(
                                              width: 160,
                                              height: 160,
                                              child: Image.file(
                                                File(cubit.imageUrl),
                                                //fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        backgroundColor: Colors.grey.shade50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 18.0,
                            ),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'يجب ادخال اسم المستخدم !';
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.teal, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                                floatingLabelStyle:
                                    TextStyle(color: Colors.teal[700]),
                                labelText: 'اسم المستخدم',
                                alignLabelWithHint: true,
                                hintTextDirection: TextDirection.rtl,
                                prefixIcon: Icon(
                                  IconlyBroken.profile,
                                  color: Colors.teal[700],
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                              ),
                            ),
                            // name
                            const SizedBox(
                              height: 18.0,
                            ),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'يجب ادخال رقم الهاتف !';
                                }
                                if (value.length != 11) {
                                  return 'رقم الهاتف يجب ان يكون 11 رقم فقط';
                                }
                                if (!value.startsWith('011') &&
                                    !value.startsWith('012') &&
                                    !value.startsWith('010') &&
                                    !value.startsWith('015')) {
                                  return 'رقم الهاتف يجب ان يكون تابع لاحدى شركات المحمول المصرية';
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.teal, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                                floatingLabelStyle:
                                    TextStyle(color: Colors.teal[700]),
                                labelText: 'رقم الهاتف',
                                alignLabelWithHint: true,
                                hintTextDirection: TextDirection.rtl,
                                prefixIcon: Icon(
                                  IconlyBroken.call,
                                  color: Colors.teal[700],
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                              ),
                            ),
                            // Phone
                            const SizedBox(
                              height: 18.0,
                            ),

                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: cubit.isPassword,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'يجب ادخال كلمة السر !';
                                }
                                if (value.length < 6) {
                                  return 'كلمة السر يجب ان تتكون من 6 حروف او ارقام على الاقل';
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.teal, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                                floatingLabelStyle:
                                    TextStyle(color: Colors.teal[700]),
                                labelText: 'كلمة السر',
                                alignLabelWithHint: true,
                                hintTextDirection: TextDirection.rtl,
                                prefixIcon: Icon(
                                  IconlyBroken.password,
                                  color: Colors.teal[700],
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    cubit.changePasswordVisibility();
                                  },
                                  icon: Icon(
                                    cubit.isPassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: Colors.teal[700],
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                              ),
                            ),
                            // password
                            const SizedBox(
                              height: 18.0,
                            ),
                            SelectDropList(cubit.idOptionItemSelected,
                                cubit.idDropListModel, (optionItem) {
                              cubit.changePaperIndex(optionItem);
                            }, IconlyBroken.document),
                            const SizedBox(
                              height: 18.0,
                            ),
                            TextFormField(
                              textDirection: TextDirection.rtl,
                              controller: nationalIDController,
                              keyboardType: TextInputType.phone,
                              validator: (String? value) {
                                switch (cubit.idOptionItemSelected.title) {
                                  case "بطاقة شخصية":
                                    if (value!.isEmpty) {
                                      return 'يجب ادخال الرقم القومى !';
                                    }
                                    if (value.length != 14) {
                                      return 'الرقم القومى يجب ان يكون 14 رقم فقط';
                                    }
                                    if (value.startsWith('0')) {
                                      return 'الرقم القومى غير صالح';
                                    }
                                    break;
                                  case "جواز سفر":
                                    if (value!.isEmpty) {
                                      return 'يجب ادخال رقم جواز السفر !';
                                    }
                                    if (value.length != 9) {
                                      return 'رقم جواز السفر غير صحيح';
                                    }
                                    if (!value.startsWith('A')) {
                                      return 'رقم جواز السفر غير صحيح';
                                    }
                                    break;
                                  case "سجل تجارى":
                                    if (value!.isEmpty) {
                                      return 'يجب ادخال رقم السجل التجارى !';
                                    }
                                    break;
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.teal, width: 2.0),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                                floatingLabelStyle:
                                    TextStyle(color: Colors.teal[700]),
                                labelText: (cubit
                                            .idOptionItemSelected.title ==
                                        "نوع الوثيقة")
                                    ? "نوع الوثيقة"
                                    : "رقم ${cubit.idOptionItemSelected.title}",
                                alignLabelWithHint: true,
                                hintTextDirection: TextDirection.rtl,
                                prefixIcon: Icon(
                                  IconlyBroken.paper,
                                  color: Colors.teal[700],
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8.0))),
                              ),
                            ),
                            const SizedBox(
                              height: 18.0,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Wrap(children: [
                                          Material(
                                            color: Colors.transparent,
                                            elevation: 10,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(36.0)),
                                            child: InkWell(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(
                                                          36.0)),
                                              onTap: () {
                                                if (!cubit
                                                    .isCityBottomSheetShown) {
                                                  cubit.showCityBottomSheet(
                                                      context);
                                                }
                                              },
                                              child: Container(
                                                width: 120,
                                                padding: const EdgeInsets
                                                        .symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 12.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .all(
                                                          Radius.circular(
                                                              36.0)),
                                                  color: Colors.teal[700],
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "اختر المحافظة",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight
                                                                .w800),
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24.0),
                                          child: Text(
                                            cubit.selectedCityName,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 18.0,
                                ),
                                Column(
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Wrap(children: [
                                          Material(
                                            color: Colors.transparent,
                                            elevation: 10,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(36.0)),
                                            child: InkWell(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(
                                                          36.0)),
                                              onTap: () {
                                                if (cubit
                                                        .selectedCityName ==
                                                    "") {
                                                  showToast(
                                                    message:
                                                        'يجب اختيار المحافظة اولاً',
                                                    length:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 3,
                                                  );
                                                } else {
                                                  if (!cubit
                                                      .isRegionBottomSheetShown) {
                                                    cubit
                                                        .getUserRegion(cubit
                                                            .selectedCityID!
                                                            .round())
                                                        .then((value) {
                                                      cubit
                                                          .showRegionBottomSheet(
                                                              context);
                                                    });
                                                  }
                                                }
                                              },
                                              child: Container(
                                                width: 120,
                                                padding: const EdgeInsets
                                                        .symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 12.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .all(
                                                          Radius.circular(
                                                              36.0)),
                                                  color: Colors.teal[700],
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "اختر المنطقة",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight
                                                                .w800),
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24.0),
                                          child: Text(
                                            cubit.selectedRegionName,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            BuildCondition(
                              condition: state is CustomerRegisterLoadingState,
                              fallback: (context) => defaultButton(
                                function: ()async {
                                  var connectivityResult =
                                  await (Connectivity().checkConnectivity());
                                  if (connectivityResult == ConnectivityResult.none) {
                                    showToast(
                                      message: 'تحقق من اتصالك بالانترنت اولاً',
                                      length: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                    );
                                  } else {
                                    if (cubit.idOptionItemSelected.title ==
                                        "نوع الوثيقة") {
                                      showToast(
                                        message: 'يجب اختيار نوع الوثيقة',
                                        length: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                      );
                                      return;
                                    }
                                    if (cubit.selectedCityName == "") {
                                      showToast(
                                        message: 'يجب اختيار المحافظة',
                                        length: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                      );
                                      return;
                                    }
                                    if (cubit.selectedRegionName == "") {
                                      showToast(
                                        message: 'يجب اختيار المنطقة',
                                        length: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                      );
                                      return;
                                    }
                                    if (cubit.emptyImage == true) {
                                      showToast(
                                        message: 'يجب اختيار الصورة الشخصية',
                                        length: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                      );
                                      return;
                                    }
                                    if (formKey.currentState!.validate()) {
                                      cubit.uploadUserFirebase(
                                          nameController.text.toString(),
                                          phoneController.text.toString(),
                                          passwordController.text.toString(),
                                          cubit.idOptionItemSelected.title,
                                          nationalIDController.text.toString(),
                                          cubit.selectedCityName,
                                          cubit.selectedRegionName);
                                    }
                                  }
                                },
                                text: "تسجيل",
                                background: Colors.teal[700]!,
                              ),
                              builder: (context) => Center(child: CircularProgressIndicator(color: Colors.teal[700], strokeWidth: 0.8,)),
                            ),
                            const SizedBox(
                              height: 36.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        );
      }),
    );
  }
}
