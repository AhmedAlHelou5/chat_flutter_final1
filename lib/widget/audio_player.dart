import 'package:flutter/material.dart';
import 'package:voice_message_package/voice_message_package.dart';

class AudioPlayers extends StatefulWidget {
  final String? url;
  final bool? isMe;

  AudioPlayers(this.url, this.isMe);

  @override
  State<AudioPlayers> createState() => _AudioPlayersState();
}

class _AudioPlayersState extends State<AudioPlayers> {
  @override
  Widget build(BuildContext context) {
    return VoiceMessage(
          audioSrc: widget.url!,
          me: !widget.isMe!,
          meBgColor: Colors.pinkAccent,
          mePlayIconColor: Colors.pink,
          noiseCount: 30,
          contactFgColor: Colors.pink,
          contactPlayIconColor: Colors.white,
          contactBgColor: Theme.of(context).disabledColor,

    );
    //   AudioWidget.network(
    //   url: widget.url!,
    //   play: _play,
    //
    //   onReadyToPlay: (total) {
    //
    //     setState(() {
    //       _loading=true;
    //       start = '${duration.mmSSFormat}';
    //       end = ' ${total.mmSSFormat}';
    //
    //     });
    //   },
    //
    //   onPositionChanged: (current, total) {
    //     setState(() {
    //       _loading=true;
    //       // _currentPosition = '${current.mmSSFormat} / ${total.mmSSFormat}';
    //       start = '${current.mmSSFormat}';
    //       end = ' ${total.mmSSFormat}';
    //
    //
    //     },
    //    );
    //
    //
    //   },
    //
    //   volume: 0.5,
    //   loopMode: LoopMode.single,
    //   onFinished:  () =>  _play = !_play,
    // child:
    //   Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children:[
    //       ElevatedButton(
    //           style: ElevatedButton.styleFrom(
    //             shape: CircleBorder(),
    //             primary: Theme.of(context).primaryColor,
    //           ),
    //           onPressed: () {
    //             assetsAudioPlayer.open(
    //                 Audio.network(widget.url!,cached: true),
    //                 seek: duration
    //             );
    //             assetsAudioPlayer.play();
    //             setState(() {
    //               _play = !_play;
    //               if(_play==false)
    //                 assetsAudioPlayer.pause();
    //
    //             });
    //           },
    //           child: Icon(
    //             _play ? Icons.pause : Icons.play_arrow,
    //             color: Colors.white,
    //           ),
    //         ),
    //       Text(start),
    //       // Container(
    //       //   width: 130,
    //       //   child:
    //       //   Slider(
    //       //     min: 0,
    //       //     max: duration.inSeconds.toDouble(),
    //       //     value: position.inSeconds.toDouble(),
    //       //     onChanged: (value) {
    //       //       setState(() {
    //       //         value = Duration(seconds: value.toInt()) as double;
    //       //
    //       //       });
    //       //     },
    //       //                 // ),
    //       // ),
    //       // ),
    //       Container(
    //         width: 100,
    //         child: Slider(
    //             value:duration.inSeconds.toDouble(),
    //             min: 0.0,
    //             max: duration.inSeconds.toDouble(),
    //             onChanged: (value) {
    //               // assetsAudioPlayer.current.value?.index = value;
    //
    //               setState(() {
    //                 value =duration.inSeconds.toDouble();
    //
    //
    //               });}),
    //       ),
    //
    //
    //       Container(
    //         margin:EdgeInsets.only(right: 10),
    //         child:!_loading? CircularProgressIndicator() : Text(end),
    //
    //       ),
    //
    //
    //
    //
    //
    //
    //     ],)
    // );
  }
}

// Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//     CircleAvatar(
//       radius: 25,
//       child: IconButton(
//         icon: Icon(
//           _play ? Icons.pause : Icons.play_arrow,
//         ),
//         onPressed: (){
//           if(_play)
//           {
//             player.pause();
//           }
//           else{
//             player.play(UrlSource(url));
//           }
//         },
//       ),
//     ),
//     SizedBox(width: 20,),
//     CircleAvatar(
//       radius: 25,
//       child: IconButton(
//         icon:const Icon(Icons.stop),
//         onPressed: (){
//           player.stop();
//         },
//       ),
//     ),
//
//
//   ],
// ),