import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:future_of_egypt_client/models/chat_model.dart';
import 'package:future_of_egypt_client/modules/chat/cubit/conversation_details_cubit.dart';
import 'package:future_of_egypt_client/modules/chat/cubit/conversation_details_state.dart';
import 'package:future_of_egypt_client/modules/chat/screens/gallery_screen.dart';
import 'package:future_of_egypt_client/modules/chat/screens/transition_app_bar.dart';
import 'package:future_of_egypt_client/shared/audio_widget.dart';
import 'package:future_of_egypt_client/shared/components.dart';

class ConversationDetailsScreen extends StatefulWidget {
  ConversationDetailsScreen({Key? key, required this.messagesList})
      : super(key: key);

  final List<ChatModel> messagesList;

  @override
  State<ConversationDetailsScreen> createState() =>
      _ConversationDetailsScreenState();
}

class _ConversationDetailsScreenState extends State<ConversationDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ConversationDetailsCubit()..sortMessages(widget.messagesList),
      child: BlocConsumer<ConversationDetailsCubit, ConversationDetailsState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = ConversationDetailsCubit.get(context);
          print(cubit.audio[0].fileName);
          return DefaultTabController(
            length: 3,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: darkColor,
                appBar: AppBar(
                  backgroundColor: darkColor,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 170,
                  flexibleSpace: Container(
                    height: 170,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/logo.jpg'),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('مستقبل مصر'),
                        SizedBox(
                          height: 5,
                        ),
                        Text('mazenelgamal@gmail.com'),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 5,
                          color: lightColor,
                        ),
                      ],
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: lightColor,
                    tabs: [
                      Tab(
                        child: Center(
                          child: Text(
                            'Photo',
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                      ),
                      Tab(
                        child: Center(
                          child: Text('voice', style: TextStyle(fontSize: 19)),
                        ),
                      ),
                      Tab(
                        child: Center(
                          child: Text('Files', style: TextStyle(fontSize: 19)),
                        ),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: GridView.builder(
                      itemCount: cubit.images.length,
                      itemBuilder: (ctx,index){
                        return  InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return Gallery(images: cubit.images,index: index);
                                },
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: cubit.images[index].fileName,
                            imageBuilder: (context, imageProvider) => ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                image: imageProvider,
                                placeholder: const AssetImage(
                                    "assets/images/placeholder.jpg"),
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
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
                        );
                      },
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2),

                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                        itemCount: cubit.audio.length,
                        itemBuilder: (ctx, index) {
                          return InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        decoration:  BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                                          ),
                                        ),

                                        height: MediaQuery.of(context).size.height * .45,
                                        width: MediaQuery.of(context).size.width * .7,
                                        child: AudioWidget(url: cubit.audio[index].message),
                                      ),
                                    ),
                                  )
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10) ,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex:1,
                                          child: Image.asset(
                                              'assets/images/headphone.png')
                                      ),
                                      Flexible(
                                        flex: 2,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(cubit.audio[index].senderID ==
                                                  'Future Of Egypt'
                                              ? cubit.audio[index].senderID
                                              : 'Me'),
                                          Text(cubit.audio[index].messageFullTime)
                                        ],

                                      )
                                      )
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                        itemCount: cubit.files.length,
                        itemBuilder: (ctx, index) {
                          return InkWell(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(10) ,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          flex:1,
                                          child: Image.asset(
                                              'assets/images/folder.png')
                                      ),
                                      Flexible(
                                          flex: 2,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(cubit.audio[index].senderID ==
                                                  'Future Of Egypt'
                                                  ? cubit.audio[index].senderID
                                                  : 'Me'),
                                              Text(cubit.audio[index].messageFullTime)
                                            ],

                                          )
                                      )
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
