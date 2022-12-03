import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

// class ShowStoryView extends StatelessWidget {
//   final String? username;
//   final String? image;
//
//   ShowStoryView(this.username, this.image);
//
//   final StoryController controller = StoryController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(username!),
//       ),
//       body: Container(
//         margin: EdgeInsets.all(
//           8,
//         ),
//         child: ListView(
//           children: <Widget>[
//             Container(
//               height: MediaQuery.of(context).size.height * 0.80,
//               child: StoryView(
//                 controller: controller,
//                 storyItems: [
//
//                   StoryItem.inlineImage(
//                     url: '$image',
//                     controller: controller,
//
//                   ),
//
//                 ],
//                 onStoryShow: (s) {
//                   print("Showing a story");
//                 },
//                 onComplete: () {
//                   print("Completed a cycle");
//                 },
//                 progressPosition: ProgressPosition.bottom,
//                 repeat: false,
//                 inline: true,
//               ),
//             ),
//             Material(
//               child: InkWell(
//                 onTap: () {
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => MoreStories(username,image)));
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius:
//                       BorderRadius.vertical(bottom: Radius.circular(8))),
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Icon(
//                         Icons.arrow_forward,
//                         color: Colors.white,
//                       ),
//                       SizedBox(
//                         width: 16,
//                       ),
//                       Text(
//                         "View more stories",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class MoreStories extends StatefulWidget {
  final String? username;
  final String? image;
  final String? imageUser;


  MoreStories(this.username, this.image,this.imageUser);

  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        leading:  Stack(children: [
          Positioned(
            top: 11,
            left: -5,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

        ]),
        leadingWidth: 150,
        title: Row(
          children: [
            Container(
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.imageUser!),
              ),
            ), Container(
              margin: EdgeInsets.only(left: 7,top: 3),
                child: FittedBox(fit: BoxFit.contain,child: Text(widget.username!,style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),)),
              ),

          ],
        ),


        ),

      body: StoryView(
        storyItems: [
          StoryItem.pageImage(
            url:
            widget.image!,
            // caption: widget.username,
            controller: storyController,
          ),

        ],
        onStoryShow: (s) {
          print("Showing a story");
        },
        onComplete: () {
          print("Completed a cycle");
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ),
    );
  }
}

