import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:chewie_video_demo_corner/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PlayerDemo extends StatefulWidget {
  const PlayerDemo({
    Key? key,
    this.title = '',
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _PlayerDemoState();
  }
}

class _PlayerDemoState extends State<PlayerDemo> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  List<String> srcs = [
    "https://res.cloudinary.com/dtdnarsy1/video/upload/v1661926846/videoplayback_lrigan.mp4",
    "https://res.cloudinary.com/dtdnarsy1/video/upload/v1661926657/get_mbhcvn.mp4",
    "https://res.cloudinary.com/dtdnarsy1/video/upload/v1661926678/get_eu56us.mp4",
    "https://res.cloudinary.com/dtdnarsy1/video/upload/v1661918926/ive_fmlybl.mp4",
    "https://res.cloudinary.com/dtdnarsy1/video/upload/v1661918923/instagram_video_kjgarl.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-spinning-around-the-earth-29351-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"
  ];

  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.network(srcs[currPlayIndex]);
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    // μλ§ μΈν
    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'μλ§1',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
          ],
        ),
      ),
    ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      // sub
      // aspectRatio: _videoPlayerController1.value.aspectRatio,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      deviceOrientationsOnEnterFullScreen:
          _videoPlayerController1.value.aspectRatio == 16 / 9
              ? [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ] : [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ],

      // μ€μ  μμ
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'λΉλμ€ μ ν',
          ),
        ];
      },
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: 'μ¬μμλ',
        cancelButtonText: 'λ«κΈ°',
      ),

      // μλ§ μΈν
/*
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),
*/

      // controls μ¨κΉ νμ΄λ¨Έ
      hideControlsTimer: const Duration(seconds: 3),

      // νλ μ΄μ΄ μ΅μ:
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.black12,
      ),
      placeholder: Container(
        color: Colors.black,
      ),
      // autoInitialize: true,
    );

  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= srcs.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }
  Future<void> prevVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex -= 1;
    if (currPlayIndex < 0) {
      currPlayIndex = srcs.length;
    }
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: AppTheme.light.copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        appBar: null,
        body: Column(
          children: <Widget>[
            Expanded(
                child: Center(
                  child: _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('λ‘λ©μ€..'),
                      ],
                    ),
            )),
            /*Expanded(
              child: OrientationBuilder(builder: (context, orientation) {
                if (MediaQuery.of(context).orientation == Orientation.landscape) {
                  // if ()
                  _chewieController?.enterFullScreen();
                } else {
                  // _chewieController?.exitFullScreen();
                }
                // return Container();
                })
            ),*/
            TextButton(
              onPressed: () {
                _chewieController?.enterFullScreen();
              },
              child: const Text('Fullscreen'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (_platform == TargetPlatform.windows) {
                          _platform = Theme.of(context).platform;
                        } else {
                          _platform = TargetPlatform.windows;
                        }
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("μ»€μ€ν μ»¨νΈλ‘€"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: prevVideo,
                      child: const Text('μ΄μ  μμ')),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: toggleVideo, child: const Text('λ€μ μμ')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
