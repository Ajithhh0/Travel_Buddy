import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class RecordingButton extends StatefulWidget {
  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton> {
  final RxBool isRecording = false.obs;
  late Timer _timer;
  final _start = 0.obs;

  // Audio player instance for press and release sounds
  late AudioPlayer audioPlayer;

  // WebSocket channel for real-time communication
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _startTimer();

    channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080'));

    // Listen for incoming audio data
    channel.stream.listen((data) {
      // Play the received audio data --- implement channel
      audioPlayer.play(BytesSource(data));
    });
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        _start.value++;
      },
    );
  }

  void _stopTimer() {
    _timer.cancel();
    _start.value = 0;
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    _start.value = 0;
    channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            RecordingButtonContent(
              isRecording: isRecording,
              onStop: _stopTimer,
              onStart: _startTimer,
              audioPlayer: audioPlayer,
              start: _start,
              channel: channel,
            ),
            isRecording.value
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.10,
                    left: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      "$_start",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ))
                : SizedBox(),
            isRecording.value
                ? Positioned(
                    left: 5,
                    top: MediaQuery.of(context).size.height * 0.07,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey,
                      child: Center(
                        child: IconButton(
                          iconSize: 32,
                          icon: Icon(Icons.delete_rounded),
                          color: Colors.black12,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ));
  }
}

class RecordingButtonContent extends StatefulWidget {
  final RxBool isRecording;
  final Function onStop;
  final Function onStart;
  final AudioPlayer audioPlayer;
  final RxInt start;
  final WebSocketChannel channel;

  RecordingButtonContent({
    required this.isRecording,
    required this.onStop,
    required this.onStart,
    required this.audioPlayer,
    required this.start,
    required this.channel,
  });

  @override
  State<RecordingButtonContent> createState() => _RecordingButtonContentState();
}

class _RecordingButtonContentState extends State<RecordingButtonContent> {
  late WebSocketChannel channel;
  late StreamSubscription<RawSocketEvent> recordingSubscription;
  late RawDatagramSocket recordingSocket;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
    _listenForIncomingAudio();
    _startRecording();
  }

 void _startRecording() async {
    recordingSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    recordingSubscription = recordingSocket.cast<Uint8List>().listen((data) {
      channel.sink.add(data);
    }) as StreamSubscription<RawSocketEvent>;
  }

  void _listenForIncomingAudio() {
    channel.stream.listen((data) {
      // Play the received audio data
      widget.audioPlayer.play(BytesSource(data));
    });
  }

  @override
  void dispose() {
    recordingSubscription.cancel();
    recordingSocket.close();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        //haptics on clicking the button
        HapticFeedback.lightImpact();

        // Start recording
        widget.isRecording.value = true;
        widget.onStart();
        widget.audioPlayer.play(AssetSource('audio/talk.mp3'));
        // Add your logic to start recording here
        widget.channel.sink.add([1, 2, 3]);
      },
      onTapUp: (_) {
        // Stop recording
        widget.isRecording.value = false;
        widget.onStop();
        widget.audioPlayer.play(AssetSource('audio/not.mp3'));
        widget.start.value = 0;

        // widget.audioCache.load("assets/audio/not.mp3");
        // Add your logic to stop recording here
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        transform: widget.isRecording.value
            ? Matrix4.translationValues(0, 0, 0) *
                Matrix4.diagonal3Values(
                    1.0, 1.0, 1.0) // push down and scale when pressed
            : Matrix4.translationValues(
                0, 0, 0), // back to original position when released
        child: Container(
          height: widget.isRecording.value
              ? MediaQuery.of(context).size.height * 0.55
              : MediaQuery.of(context).size.height *
                  0.60, // smaller height when pressed
          width: widget.isRecording.value
              ? MediaQuery.of(context).size.width * 0.55
              : MediaQuery.of(context).size.width *
                  0.60, // smaller width when pressed
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              border: widget.isRecording.value
                  ? null
                  : Border.all(color: Colors.grey, width: 4),
              shape: BoxShape.circle,
              gradient: widget.isRecording.value
                  ? LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                          Colors.green.shade200,
                          Colors.green.shade200,
                        ])
                  : LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.blue.shade200,
                        Colors.orange.shade200,
                      ],
                    )),
          child: widget.isRecording.value
              ? Center(
                  child: Icon(
                    Icons.multitrack_audio_rounded,
                    color: Colors.black12,
                    size: 48,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.multitrack_audio_rounded,
                      color: Colors.black12,
                      size: 48,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Push to talk",
                      style: TextStyle(color: Colors.black12.withOpacity(0.5)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
