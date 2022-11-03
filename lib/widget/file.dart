import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';


class FileMessage extends StatefulWidget {
  final String? url;
  final bool? isMe;


  FileMessage(this.url, this.isMe);

  @override
  State<FileMessage> createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage> {

  String progress = "0";


    var dio=Dio();





  void download2(Dio dio, String url, String savePath) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    //get pdf from link
    try{
    Response response = await dio.get(
      url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );

    //write in download folder
    File file = File(savePath) ;
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloaded successfully')));

    } catch(e){

      print('error: is');
      print(e);

        }
  }
void showDownloadProgress(received,total) {
  if (total != -1) {
    print((received / total * 100).toStringAsFixed(0) + "%");
  }
}


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (_) =>  PDFViewerCachedFromUrl(
              url: widget.url!,
            ),
          ),
        );
        
        print ('aaaaa ${widget.url}  file pdf ');

      },


      child: Container(
        width: 150,

        margin: EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Stack(
                  alignment:
                  AlignmentDirectional.center,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.pink[100],
                      height: 60,
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: Theme.of(context)
                              .primaryColor,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'File',
                          style: TextStyle(
                              fontSize: 20,
                              color: widget.isMe!
                                  ? Colors.pink[300]
                                  : Colors.pink),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.pink[200],
                    child: IconButton(
                        icon: Icon(
                          Icons.file_download,
                          color: widget.isMe!
                              ? Colors.pink
                              : Colors.pink,
                        ),
                        onPressed: () async{
                          String path =await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);

                          String fullPath = "$path/${DateTime.now().millisecondsSinceEpoch}.pdf";
                          download2(dio, widget.url!, fullPath);

                          print(widget.url);
                        }
                      // downloadFile(filePath: widget.file!,url: widget.file!),

                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PDFViewerFromUrl extends StatelessWidget {
  PDFViewerFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF From Url'),
      ),
      body: const PDF().fromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}


class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
      ),
      body: const PDF().cachedFromUrl(

        url,
        placeholder: (double progress) => Center(child: CircularProgressIndicator(value: double.tryParse('$progress %'),)),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }




}