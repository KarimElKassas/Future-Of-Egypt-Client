import 'package:animate_do/animate_do.dart';
import 'package:buildcondition/buildcondition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_of_egypt_client/modules/chat/cubit/display_chats_cubit.dart';

import '../cubit/display_chats_states.dart';
import 'conversation_screen.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerDisplayChatsCubit()..getChats(),
      child: BlocConsumer<CustomerDisplayChatsCubit, CustomerDisplayChatsStates>(
          listener: (context, state){
          },
          builder: (context, state){

            var cubit = CustomerDisplayChatsCubit.get(context);

            return  Scaffold(
                appBar: AppBar(
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
                    statusBarBrightness: Brightness.light, // For iOS (dark icons)
                  ),
                  elevation: 0.0,
                  toolbarHeight: 0.0,
                  backgroundColor: Colors.transparent,
                ),
                body: BuildCondition(
                  condition: state is CustomerDisplayChatsLoadingChatsState,
                  builder: (context) => Center(child: CircularProgressIndicator(color: Colors.teal[700],),),
                  fallback: (context) => ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) => listItem(context, cubit,state, index),
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 10.0),
                    itemCount: cubit.chatList.length,
                  ),
                ),
            );
          },
      ),
    );
  }

  Widget listItem(BuildContext context, CustomerDisplayChatsCubit cubit,state, int index){

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        elevation: 2,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        shadowColor: Colors.black,
        child: InkWell(
          onTap: (){
            cubit.goToConversation(context, ConversationScreen(userID: cubit.userList[index].userID,userName: cubit.userList[index].userName,userImage: cubit.userImage!, userToken: cubit.userList[index].userToken,));
          },
          splashColor: Colors.white70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                BuildCondition(
                  condition: state is CustomerDisplayChatsLoadingChatsState,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal,)),
                  fallback: (context) => InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return SlideInUp(
                                duration: const Duration(milliseconds: 500),
                                child: Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) {
                                                return InteractiveViewer(
                                                  child: Scaffold(
                                                    backgroundColor: Colors.black,
                                                    appBar: AppBar(
                                                      systemOverlayStyle: const SystemUiOverlayStyle(
                                                        statusBarColor: Colors.black,
                                                        statusBarIconBrightness: Brightness.light,
                                                        // For Android (dark icons)
                                                        statusBarBrightness:
                                                        Brightness.dark, // For iOS (dark icons)
                                                      ),
                                                      backgroundColor: Colors.black,
                                                      elevation: 0.0,
                                                      toolbarHeight: 0,
                                                    ),
                                                    body: Center(
                                                      child: CachedNetworkImage(
                                                        imageUrl: cubit.userList[index].userImage,
                                                        imageBuilder: (context, imageProvider) => ClipRRect(
                                                          borderRadius: BorderRadius.circular(0.0),
                                                          child: FadeInImage(
                                                            fit: BoxFit.fill,
                                                            image: imageProvider,
                                                            placeholder: const AssetImage(
                                                                "assets/images/placeholder.jpg"),
                                                            imageErrorBuilder: (context, error, stackTrace) {
                                                              return Image.asset(
                                                                'assets/images/error.png',
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        placeholder: (context, url) => const Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors.teal,
                                                              strokeWidth: 0.8,
                                                            )),
                                                        errorWidget: (context, url, error) =>
                                                        const FadeInImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage("assets/images/error.png"),
                                                          placeholder:
                                                          AssetImage("assets/images/placeholder.jpg"),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  maxScale: 3.5,
                                                  panEnabled: true,
                                                  scaleEnabled: true,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: cubit
                                              .userList[index]
                                              .userImage,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(12.0),
                                                child: FadeInImage(
                                                  height: 400,
                                                  width: double.infinity,
                                                  fit: BoxFit.fill,
                                                  image: imageProvider,
                                                  placeholder: const AssetImage(
                                                      "assets/images/placeholder.jpg"),
                                                  imageErrorBuilder:
                                                      (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/error.png',
                                                      fit: BoxFit.fill,
                                                      height: 50,
                                                      width: 50,
                                                    );
                                                  },
                                                ),
                                              ),
                                          placeholder: (context, url) =>
                                          const CircularProgressIndicator(color: Colors.teal, strokeWidth: 0.8,),
                                          errorWidget: (context, url, error) =>
                                          const FadeInImage(
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.fill,
                                            image: AssetImage(
                                                "assets/images/error.png"),
                                            placeholder: AssetImage(
                                                "assets/images/placeholder.jpg"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: cubit.userList[index].userImage,
                      imageBuilder: (context, imageProvider) => ClipOval(
                        child: FadeInImage(
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                          image: imageProvider,
                          placeholder:
                          const AssetImage("assets/images/placeholder.jpg"),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/error.png',
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            );
                          },
                        ),
                      ),
                      placeholder: (context, url) => const CircularProgressIndicator(color: Colors.teal, strokeWidth: 0.8,),
                      errorWidget: (context, url, error) => const FadeInImage(
                        height: 50,
                        width: 50,
                        fit: BoxFit.fill,
                        image: AssetImage("assets/images/error.png"),
                        placeholder:
                        AssetImage("assets/images/placeholder.jpg"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0,),
                Text(
                  cubit.userList[index].userName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
    setState(() {

    });
    print("app in initstate \n");

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed\n");

        break;
      case AppLifecycleState.inactive:
        print("app in inactive\n");
        break;
      case AppLifecycleState.paused:
        print("app in paused\n");
        break;
      case AppLifecycleState.detached:
      //await SocialHomeCubit.get(context).logOut(context);
      //await logOut();
        print("app in detached\n");
        break;
    }
  }
}
