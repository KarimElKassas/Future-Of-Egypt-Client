import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:future_of_egypt_client/shared/components.dart';
import 'package:future_of_egypt_client/shared/page_manager.dart';

class AudioWidget extends StatefulWidget {
   AudioWidget({Key? key,required this.url}) : super(key: key);
  String url ;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  late final PageManager _pageManager;
  @override
  void initState() {
    _pageManager = PageManager(widget.url);
    _pageManager.play();
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
    return Scaffold(

      backgroundColor: darkColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration:  BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/headphone.png'),
              ValueListenableBuilder<ProgressBarState>(
                valueListenable: _pageManager.progressNotifier,
                builder: (_, value, __) {
                  return ProgressBar(

                    progress: value.current,
                    buffered: value.buffered,
                    total: value.total,
                  );
                },
              ),
              ValueListenableBuilder<ButtonState>(
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
            ],
          ),
        ),
      ),
    );
  }
}
