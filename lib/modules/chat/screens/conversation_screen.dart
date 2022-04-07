import 'package:buildcondition/buildcondition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_of_egypt_client/modules/chat/screens/chat_opened_image_screen.dart';
import 'package:galleryimage/gallery_Item_model.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:transition_plus/transition_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/components.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_states.dart';
import 'input_field_widget.dart';

class ConversationScreen extends StatefulWidget {
  final String userID;
  final String userName;
  final String userImage;
  final String userToken;

  const ConversationScreen(
      {Key? key,
      required this.userID,
      required this.userName,
      required this.userImage,
      required this.userToken})
      : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<GalleryItemModel> galleryItems = <GalleryItemModel>[];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationCubit()
        ..getUserData()
        ..initRecorder()
        ..getMessages(),
      child: BlocConsumer<ConversationCubit, ConversationStates>(
        listener: (context, state) {
          if (state is ConversationSendMessageErrorState) {
            showToast(
                message: state.error,
                length: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3);
          }
          if (state is ConversationDownloadFileErrorState) {
            showToast(
                message: state.error,
                length: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3);
          }
        },
        builder: (context, state) {
          var cubit = ConversationCubit.get(context);

          return Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logoWhite.png'),
                  fit: BoxFit.fitWidth,
                ),
                color: Colors.white),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  // For Android (dark icons)
                  statusBarBrightness: Brightness.light, // For iOS (dark icons)
                ),
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                flexibleSpace: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              IconlyBroken.arrowRightCircle,
                              color: Colors.black,
                            ),
                          ),
                          CachedNetworkImage(
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/mostaqbal-masr.appspot.com/o/Clients%2FFuture%20Of%20Egypt.jpg?alt=media&token=9c330dd7-7554-420c-9523-60bf5a5ec71e",
                            imageBuilder: (context, imageProvider) => ClipOval(
                              child: FadeInImage(
                                height: 50,
                                width: 50,
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
                            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.teal, strokeWidth: 0.8,),
                            errorWidget: (context, url, error) =>
                            const FadeInImage(
                              height: 50,
                              width: 50,
                              fit: BoxFit.fill,
                              image: AssetImage("assets/images/error.png"),
                              placeholder:
                              AssetImage("assets/images/placeholder.jpg"),
                            ),
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Flexible(
                            //flex: 3,
                            child: InkWell(
                              onTap: (){
                                //cubit.navigateToDetails(context, widget.groupID, widget.groupName, widget.groupImage, widget.membersList, widget.adminsList);
                              },
                              splashColor: Colors.transparent,
                              child: Text(
                                widget.userName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BuildCondition(
                          condition:
                          state is ConversationLoadingMessageState,
                          fallback: (context) => ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: cubit.chatListReversed.length,
                              itemBuilder: (context, index) =>
                                  chatView(context, cubit, index, state)),
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          )),
                    ),
                  ),
                  InputFieldWidget(
                    userID: widget.userID,
                    userToken: widget.userToken,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget chatView(BuildContext context, ConversationCubit cubit, int index,
      ConversationStates state) {
    if (cubit.chatListReversed[index].type == "Text") {
      return Container(
          padding: cubit.chatListReversed[index].senderID == cubit.userID ? const EdgeInsets.only(top: 10, bottom: 10, left: 16) : const EdgeInsets.only(top: 10, bottom: 10, right: 16),
          child: Align(
            alignment: (cubit.chatListReversed[index].senderID == cubit.userID
                ? Alignment.topRight
                : Alignment.topLeft),
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                cubit.chatListReversed[index].senderID == cubit.userID
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(14.0),
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                )
                    : const BorderRadius.only(
                  topRight: Radius.circular(14.0),
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),
                color: (cubit.chatListReversed[index].senderID == cubit.userID
                    ? Colors.teal
                    : Colors.grey.shade200),
              ),
              padding:
              const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    text: cubit.chatListReversed[index].message.toString(),
                    style: TextStyle(
                      color:
                      cubit.chatListReversed[index].senderID == cubit.userID
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black,
                      fontSize: 11.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                    linkStyle: TextStyle(
                      color: Colors.cyanAccent.shade700,
                      fontSize: 11.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    cubit.chatListReversed[index].messageTime,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                      cubit.chatListReversed[index].senderID == cubit.userID
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
      );
    } else {
      return imageMessageView(context, cubit, index, state);
    }
  }

  Widget imageMessageView(BuildContext context, ConversationCubit cubit,
      int index, ConversationStates state) {
    if (cubit.chatListReversed[index].type == "Image") {
      return Align(
        alignment: cubit.chatListReversed[index].senderID == cubit.userID
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(context, ScaleTransition1(page: ChatOpenedImageScreen(imageUrl: cubit.chatListReversed[index].fileName,), startDuration: const Duration(milliseconds: 1000),closeDuration: const Duration(milliseconds: 600), type: ScaleTrasitionTypes.bottomRight));
            },
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.60, // 45% of total width
              height: 300,
              decoration: BoxDecoration(
                  borderRadius:
                  cubit.chatListReversed[index].senderID == cubit.userID
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(14.0),
                    bottomLeft: Radius.circular(14.0),
                    bottomRight: Radius.circular(14.0),
                  )
                      : const BorderRadius.only(
                    topRight: Radius.circular(14.0),
                    bottomLeft: Radius.circular(14.0),
                    bottomRight: Radius.circular(14.0),
                  ),
                  color: (cubit.chatListReversed[index].senderID == cubit.userID
                      ? Colors.teal
                      : Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: cubit.chatListReversed[index].senderID != cubit.userID
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14.0),
                            topRight: Radius.circular(14.0),
                            bottomLeft: Radius.circular(14.0),
                            bottomRight: Radius.circular(14.0)),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          imageUrl: cubit
                              .chatListReversed[index].fileName
                              .toString(),
                          imageBuilder: (context, imageProvider) =>
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
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
                            image:
                            AssetImage("assets/images/error.png"),
                            placeholder: AssetImage(
                                "assets/images/placeholder.jpg"),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ClipRRect(
                    borderRadius:
                    cubit.chatListReversed[index].senderID !=
                        cubit.userID
                        ? const BorderRadius.only(
                      topLeft: Radius.circular(14.0),
                      bottomLeft: Radius.circular(14.0),
                      bottomRight: Radius.circular(14.0),
                    )
                        : const BorderRadius.only(
                      topRight: Radius.circular(14.0),
                      bottomLeft: Radius.circular(14.0),
                      bottomRight: Radius.circular(14.0),
                    ),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: cubit.chatListReversed[index].fileName,
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
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
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.9),
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
              ),
            ),
          ),
        ),
      );
    } else {
      return fileMessageView(cubit, index, state);
    }
  }

  Widget multipleImageMessageView(BuildContext context, ConversationCubit cubit,
      int index, ConversationStates state) {
    if (cubit.chatListReversed[index].type == "Image") {
      return Align(
      alignment: cubit.chatListReversed[index].receiverID == cubit.userID
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: cubit.chatListReversed[index].messageImages![0]
                          .toString()
                          .replaceAll("[", "")
                          .replaceAll("]", ""),
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: FadeInImage(
                          height: double.infinity,
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
                              height: double.infinity,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                      placeholder: (context, url) => const FadeInImage(
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        image:
                        AssetImage("assets/images/placeholder.jpg"),
                        placeholder:
                        AssetImage("assets/images/placeholder.jpg"),
                      ),
                      errorWidget: (context, url, error) =>
                      const FadeInImage(
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        image: AssetImage("assets/images/error.png"),
                        placeholder:
                        AssetImage("assets/images/placeholder.jpg"),
                      ),
                    ),
                    maxScale: 3.5,
                    panEnabled: false,
                  );
                },
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.65, // 45% of total width
            height: 300,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.teal
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0)),
                  child: FadeInImage(
                    height: 140,
                    width: MediaQuery.of(context).size.width *
                        0.60 * 0.5,
                    fit: BoxFit.fill,
                    image:
                    NetworkImage(cubit.chatListReversed[index].messageImages![0]
                        .toString()
                        .replaceAll("[", "")
                        .replaceAll("]", "")),
                    placeholder:
                    const AssetImage("assets/images/placeholder.jpg"),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/error.png',
                        fit: BoxFit.fill,
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    } else {
      return fileMessageView(cubit, index, state);
    }
  }

/*
  Widget galleryImageMessageView(BuildContext context, ConversationCubit cubit,
      int index, ConversationStates state) {
    if (cubit.chatListReversed[index].type == "Image") {
      return Align(
        alignment: cubit.chatListReversed[index].receiverID == cubit.userID
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.65, // 45% of total width
            height: 300,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.teal
            ),
            child: Padding(
                padding: const EdgeInsets.all(4),
                child: cubit.chatListReversed[index].messageImages!.isEmpty
                    ? getEmptyWidget()
                    : GridView.builder(
                    primary: false,
                    itemCount: cubit.chatListReversed[index].messageImages!.length > 3 ? 3 : cubit.chatListReversed[index].messageImages!.length,
                    padding: const EdgeInsets.all(0),
                    semanticChildCount: 1,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 5, crossAxisSpacing: 3),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          // if have less than 4 image we build GalleryItemThumbnail
                          // if have mor than 4 build image number 3 with number for other images
                          child: cubit.chatListReversed[index].messageImages!.length > 3 && index == 2
                              ? buildImageNumbers(index,cubit)
                              : GalleryThumbnail(
                            galleryItem: cubit.chatListReversed[index].messageImages![index]!,
                            onTap: () {
                              //openImageFullScreen(index, cubit);
                            },
                          ));
                    })),
          ),
        ),
      );
    } else {
      return fileMessageView(cubit, index);
    }
  }
*/

  Widget fileMessageView(ConversationCubit cubit, int index, ConversationStates state) {
    return cubit.chatListReversed[index].type == "file"
        ? Align(
      alignment: cubit.chatListReversed[index].senderID == cubit.userID
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.65, // 45% of total width
          //height: 60,
          decoration: BoxDecoration(
            borderRadius: cubit.chatListReversed[index].senderID == cubit.userID ? const BorderRadius.only(
              topLeft: Radius.circular(14.0),
              bottomLeft: Radius.circular(14.0),
              bottomRight: Radius.circular(14.0),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(14.0),
              bottomLeft: Radius.circular(14.0),
              bottomRight: Radius.circular(14.0),
            ),
            color: cubit.chatListReversed[index].senderID == cubit.userID
                ? Colors.teal
                : Colors.grey.shade200,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: cubit.chatListReversed[index].senderID ==
                      cubit.userID
                      ? InkWell(
                    onTap: () {
                      if (cubit.checkForDocumentFile(
                          cubit.chatListReversed[index].fileName)) {
                        OpenFile.open(
                            "/storage/emulated/0/Download/Future Of Egypt Media Client/Documents/${cubit.chatListReversed[index].fileName}");
                      } else {
                        cubit
                            .downloadDocumentFile(
                            cubit.chatListReversed[index].fileName)
                            .then((value) {
                          OpenFile.open(
                              "/storage/emulated/0/Download/Future Of Egypt Media Client/Documents/${cubit.chatListReversed[index].fileName}");
                        });
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2, right: 2),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              BuildCondition(
                                condition: (cubit.downloadingFileName == cubit.chatListReversed[index].fileName) || (cubit.uploadingFileName == cubit.chatListReversed[index].fileName),
                                fallback: (context) => Icon(
                                  IconlyBroken.document,
                                  color:
                                  cubit.chatListReversed[index]
                                      .senderID ==
                                      cubit.userID
                                      ? Colors.white
                                      .withOpacity(0.9)
                                      : Colors.black,
                                ),
                                builder: (context) =>
                                    CircularProgressIndicator(
                                      color:
                                      cubit.chatListReversed[index]
                                          .senderID ==
                                          cubit.userID
                                          ? Colors.white
                                          .withOpacity(0.9)
                                          : Colors.black,
                                      strokeWidth: 0.8,
                                    ),
                              ),
                              Flexible(
                                child: Text(
                                  cubit.chatListReversed[index]
                                      .fileName,
                                  style: TextStyle(
                                    color: cubit
                                        .chatListReversed[
                                    index]
                                        .senderID ==
                                        cubit.userID
                                        ? Colors.white
                                        .withOpacity(0.9)
                                        : Colors.black,
                                    fontSize: 11,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 1.0,
                        ),
                        Text(
                          cubit.chatListReversed[index].messageTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: cubit.chatListReversed[index]
                                .senderID ==
                                cubit.userID
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                      : InkWell(
                    onTap: () {
                      if (cubit.checkForDocumentFile(
                          cubit.chatListReversed[index].fileName)) {
                        OpenFile.open(
                            "/storage/emulated/0/Download/Future Of Egypt Media Client/Documents/${cubit.chatListReversed[index].fileName}");
                      } else {
                        cubit
                            .downloadDocumentFile(
                            cubit.chatListReversed[index].fileName)
                            .then((value) {
                          OpenFile.open(
                              "/storage/emulated/0/Download/Future Of Egypt Media Client/Documents/${cubit.chatListReversed[index].fileName}");
                        });
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              BuildCondition(
                                condition:
                                (cubit.downloadingFileName == cubit.chatListReversed[index].fileName) || (cubit.uploadingFileName == cubit.chatListReversed[index].fileName),
                                fallback: (context) => Icon(
                                  IconlyBroken.document,
                                  color:
                                  cubit.chatListReversed[index]
                                      .senderID ==
                                      cubit.userID
                                      ? Colors.white
                                      .withOpacity(0.9)
                                      : Colors.black,
                                ),
                                builder: (context) =>
                                    CircularProgressIndicator(
                                      color:
                                      cubit.chatListReversed[index]
                                          .senderID ==
                                          cubit.userID
                                          ? Colors.white
                                          .withOpacity(0.9)
                                          : Colors.black,
                                      strokeWidth: 0.8,
                                    ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(right: 4),
                                child: Flexible(
                                  child: Text(
                                    cubit.chatListReversed[index]
                                        .fileName,
                                    style: TextStyle(
                                      color: cubit
                                          .chatListReversed[
                                      index]
                                          .senderID ==
                                          cubit.userID
                                          ? Colors.white
                                          .withOpacity(0.9)
                                          : Colors.black,
                                      fontSize: 11,
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          cubit.chatListReversed[index].messageTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: cubit.chatListReversed[index]
                                .senderID ==
                                cubit.userID
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    )
        : audioConversationManagement(context, index, cubit);
  }

  Widget audioConversationManagement(BuildContext itemBuilderContext,
      int index, ConversationCubit cubit) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onLongPress: () async {},
            child: Container(
              margin: cubit.chatListReversed[index].senderID == cubit.userID
                  ? EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 8,
                top: 5.0,
              )
                  : EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 8,
                top: 5.0,
              ),
              alignment: cubit.chatListReversed[index].senderID == cubit.userID
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                //height: 70.0,
                width: 250.0,
                decoration: BoxDecoration(
                  color: cubit.chatListReversed[index].senderID == cubit.userID
                      ? Colors.teal
                      : Colors.grey.shade200,
                  borderRadius:
                  cubit.chatListReversed[index].senderID == cubit.userID
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(14.0),
                    bottomLeft: Radius.circular(14.0),
                    bottomRight: Radius.circular(14.0),
                  )
                      : const BorderRadius.only(
                    topRight: Radius.circular(14.0),
                    bottomLeft: Radius.circular(14.0),
                    bottomRight: Radius.circular(14.0),
                  ),
                ),
                child: cubit.chatListReversed[index].senderID == cubit.userID
                    ? Row(
                  children: [
                    const SizedBox(
                      width: 4.0,
                    ),
                    GestureDetector(
                      onLongPress: () =>
                          cubit.chatMicrophoneOnLongPressAction(),
                      onTap: () {
                        if (cubit.chatListReversed[index].senderID ==
                            cubit.userID) {
                          if (cubit.checkForAudioFile(
                              cubit.chatListReversed[index].fileName)) {
                            cubit.chatMicrophoneOnTapAction(
                                index,
                                cubit.chatListReversed[index].fileName);
                          } else {
                            cubit.downloadAudioFile(
                                cubit.chatListReversed[index].fileName,
                                index);
                          }
                        } else {
                          if (cubit.checkForAudioFile(
                              cubit.chatListReversed[index].fileName)) {
                            cubit.chatMicrophoneOnTapAction(
                                index,
                                cubit.chatListReversed[index].fileName);
                          } else {
                            cubit.downloadAudioFile(
                                cubit.chatListReversed[index].fileName,
                                index);
                          }
                        }
                      },
                      child: BuildCondition(
                        condition: (cubit.downloadingRecordName == cubit.chatListReversed[index].fileName) || (cubit.uploadingRecordName == cubit.chatListReversed[index].fileName),
                        builder: (context) => Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: CircularProgressIndicator(
                            color: cubit.chatListReversed[index].senderID ==
                                cubit.userID
                                ? Colors.white.withOpacity(0.8)
                                : Colors.teal,
                            strokeWidth: 0.8,
                          ),
                        ),
                        fallback: (context) => Icon(
                          index == cubit.lastAudioPlayingIndex
                              ? cubit.iconData
                              : Icons.play_arrow_rounded,
                          color: cubit.chatListReversed[index].senderID ==
                              cubit.userID
                              ? Colors.white.withOpacity(0.8)
                              : Colors.teal,
                          size: 40.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 26.0,
                              ),
                              child: LinearPercentIndicator(
                                percent: cubit.justAudioPlayer.duration ==
                                    null
                                    ? 0.0
                                    : cubit.lastAudioPlayingIndex == index
                                    ? cubit.currAudioPlayingTime /
                                    cubit
                                        .justAudioPlayer
                                        .duration!
                                        .inMicroseconds
                                        .ceilToDouble() <=
                                    1.0
                                    ? cubit.currAudioPlayingTime /
                                    cubit
                                        .justAudioPlayer
                                        .duration!
                                        .inMicroseconds
                                        .ceilToDouble()
                                    : 0.0
                                    : 0,
                                barRadius: const Radius.circular(8.0),
                                lineHeight: 3.5,
                                backgroundColor: cubit
                                    .chatListReversed[index]
                                    .senderID ==
                                    cubit.userID
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.teal,
                                progressColor: cubit
                                    .chatListReversed[index]
                                    .senderID ==
                                    cubit.userID
                                    ? Colors.blue
                                    : Colors.amber,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 7.0, right: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        cubit.lastAudioPlayingIndex ==
                                            index
                                            ? cubit.loadingTime
                                            : '0:00',
                                        style: TextStyle(
                                          color: cubit
                                              .chatListReversed[
                                          index]
                                              .senderID ==
                                              cubit.userID
                                              ? Colors.white
                                              .withOpacity(0.8)
                                              : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        cubit.lastAudioPlayingIndex ==
                                            index
                                            ? cubit.totalDuration
                                            : '',
                                        style: TextStyle(
                                          color: cubit
                                              .chatListReversed[
                                          index]
                                              .senderID ==
                                              cubit.userID
                                              ? Colors.white
                                              .withOpacity(0.8)
                                              : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 23.0,
                        backgroundColor:
                        cubit.chatListReversed[index].senderID ==
                            cubit.userID
                            ? const Color.fromRGBO(60, 80, 100, 1)
                            : const Color.fromRGBO(102, 102, 255, 1),
                        backgroundImage: const ExactAssetImage(
                          "assets/images/me.jpg",
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.userImage,
                          imageBuilder: (context, imageProvider) =>
                              ClipOval(
                                child: FadeInImage(
                                  height: 50,
                                  width: 50,
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
                          placeholder: (context, url) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.teal,
                          ),
                          errorWidget: (context, url, error) =>
                          const FadeInImage(
                            height: 50,
                            width: 50,
                            fit: BoxFit.fill,
                            image: AssetImage("assets/images/error.png"),
                            placeholder: AssetImage(
                                "assets/images/placeholder.jpg"),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    const SizedBox(
                      width: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CircleAvatar(
                        radius: 23.0,
                        backgroundColor:
                        cubit.chatListReversed[index].senderID ==
                            cubit.userID
                            ? const Color.fromRGBO(60, 80, 100, 1)
                            : const Color.fromRGBO(102, 102, 255, 1),
                        backgroundImage: const ExactAssetImage(
                          "assets/images/me.jpg",
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "https://firebasestorage.googleapis.com/v0/b/mostaqbal-masr.appspot.com/o/Clients%2FFuture%20Of%20Egypt.jpg?alt=media&token=9c330dd7-7554-420c-9523-60bf5a5ec71e",
                          imageBuilder: (context, imageProvider) =>
                              ClipOval(
                                child: FadeInImage(
                                  height: 50,
                                  width: 50,
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
                          placeholder: (context, url) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                          ),
                          errorWidget: (context, url, error) =>
                          const FadeInImage(
                            height: 50,
                            width: 50,
                            fit: BoxFit.fill,
                            image: AssetImage("assets/images/error.png"),
                            placeholder: AssetImage(
                                "assets/images/placeholder.jpg"),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () =>
                          cubit.chatMicrophoneOnLongPressAction(),
                      onTap: () {
                        if (cubit.chatListReversed[index].senderID ==
                            cubit.userID) {
                          if (cubit.checkForAudioFile(
                              cubit.chatListReversed[index].fileName)) {
                            cubit.chatMicrophoneOnTapAction(
                                index,
                                cubit.chatListReversed[index].fileName);
                          } else {
                            cubit.downloadAudioFile(
                                cubit.chatListReversed[index].fileName,
                                index);
                          }
                        } else {
                          if (cubit.checkForAudioFile(
                              cubit.chatListReversed[index].fileName)) {
                            cubit.chatMicrophoneOnTapAction(
                                index,
                                cubit.chatListReversed[index].fileName);
                          } else {
                            cubit.downloadAudioFile(
                                cubit.chatListReversed[index].fileName,
                                index);
                          }
                        }
                      },
                      child: BuildCondition(
                        condition: (cubit.downloadingRecordName ==
                            cubit.chatListReversed[index].fileName) || (cubit.uploadingRecordName ==
                            cubit.chatListReversed[index].fileName),
                        builder: (context) => Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: CircularProgressIndicator(
                            color: cubit.chatListReversed[index].senderID ==
                                cubit.userID
                                ? Colors.white.withOpacity(0.8)
                                : Colors.teal,
                            strokeWidth: 0.8,
                          ),
                        ),
                        fallback: (context) => Icon(
                          index == cubit.lastAudioPlayingIndex
                              ? cubit.iconData
                              : Icons.play_arrow_rounded,
                          color: cubit.chatListReversed[index].senderID ==
                              cubit.userID
                              ? Colors.white.withOpacity(0.8)
                              : Colors.teal,
                          size: 40.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 2.0, right: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 26.0,
                              ),
                              child: LinearPercentIndicator(
                                percent: cubit.justAudioPlayer.duration ==
                                    null
                                    ? 0.0
                                    : cubit.lastAudioPlayingIndex == index
                                    ? cubit.currAudioPlayingTime /
                                    cubit
                                        .justAudioPlayer
                                        .duration!
                                        .inMicroseconds
                                        .ceilToDouble() <=
                                    1.0
                                    ? cubit.currAudioPlayingTime /
                                    cubit
                                        .justAudioPlayer
                                        .duration!
                                        .inMicroseconds
                                        .ceilToDouble()
                                    : 0.0
                                    : 0,
                                barRadius: const Radius.circular(8.0),
                                lineHeight: 3.5,
                                backgroundColor: cubit
                                    .chatListReversed[index]
                                    .senderID ==
                                    cubit.userID
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.teal,
                                progressColor: cubit
                                    .chatListReversed[index]
                                    .senderID ==
                                    cubit.userID
                                    ? Colors.blue
                                    : Colors.amber,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10.0, left: 7.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        cubit.lastAudioPlayingIndex ==
                                            index
                                            ? cubit.loadingTime
                                            : '0:00',
                                        style: TextStyle(
                                          color: cubit
                                              .chatListReversed[
                                          index]
                                              .senderID ==
                                              cubit.userID
                                              ? Colors.white
                                              .withOpacity(0.8)
                                              : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        cubit.lastAudioPlayingIndex ==
                                            index
                                            ? cubit.totalDuration
                                            : '',
                                        style: TextStyle(
                                          color: cubit
                                              .chatListReversed[
                                          index]
                                              .senderID ==
                                              cubit.userID
                                              ? Colors.white
                                              .withOpacity(0.8)
                                              : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8.0,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

/*
  Widget buildImageNumbers(int index, ConversationCubit cubit) {
    return GestureDetector(
      onTap: () {
        //openImageFullScreen(index, cubit);
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[
          GalleryThumbnail(
            galleryItem: cubit.chatListReversed[index].messageImages![index]!,
          ),
          Container(
            color: Colors.black.withOpacity(.7),
            child: Center(
              child: Text(
                "+ ${cubit.chatListReversed[index].messageImages!.length - index}",
                style: const TextStyle(color: Colors.white, fontSize: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }
*/

  /*void openImageFullScreen(final int indexOfImage, ConversationCubit cubit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageWrapper(
          titleGallery: "",
          galleryItems: cubit.chatListReversed[indexOfImage].messageImages!,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: 0,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }*/
}
