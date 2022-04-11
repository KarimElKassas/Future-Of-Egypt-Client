import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:future_of_egypt_client/modules/chat/cubit/conversation_cubit.dart';
import 'package:future_of_egypt_client/shared/components.dart';
import 'package:future_of_egypt_client/shared/page_manager_chat.dart';

class AudioWidgetChat extends StatefulWidget {
  AudioWidgetChat({Key? key,required this.url, required this.cubit, required this.index}) : super(key: key);
  String url ;
  int index ;
  ConversationCubit cubit ;

  @override
  State<AudioWidgetChat> createState() => _AudioWidgetChatState();
}

class _AudioWidgetChatState extends State<AudioWidgetChat> {
  late final PageManager _pageManager;
  @override
  void initState() {
    _pageManager = PageManager(widget.url, widget.cubit, widget.index);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: ValueListenableBuilder<ButtonState>(
            valueListenable: _pageManager.buttonNotifier,
            builder: (_, value, __) {
              switch (value) {
                case ButtonState.loading:
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 32.0,
                    height: 32.0,
                    child: const CircularProgressIndicator(),
                  );
                case ButtonState.paused:
                  return IconButton(
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 32.0,
                    onPressed: _pageManager.play,
                  );
                case ButtonState.playing:
                  return IconButton(
                    icon: const Icon(Icons.pause),
                    iconSize: 32.0,
                    onPressed: _pageManager.pause,
                  );
              }
            },
          ),
        ),
        Flexible(
          flex: 8,
          child: ValueListenableBuilder<ProgressBarState>(
            valueListenable: _pageManager.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                baseBarColor: Colors.white,
                progressBarColor: Colors.yellow,
                thumbColor: Colors.red,
                thumbRadius: 8,
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
              );
            },
          ),
        ),

      ],
    );
  }
}
