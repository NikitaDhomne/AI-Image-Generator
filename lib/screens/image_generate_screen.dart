import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_generator/apis/api_services.dart';
import 'package:image_generator/material/colors.dart';
import 'package:image_generator/screens/arts_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var textController = TextEditingController();
  String image = '';
  var isLoaded = false;
  ScreenshotController screenshotController = ScreenshotController();

  shareImage() async {
    await screenshotController
        .capture(delay: Duration(milliseconds: 100), pixelRatio: 1.0)
        .then((Uint8List? img) async {
      if (img != null) {
        final directory = (await getApplicationDocumentsDirectory()).path;
        const filename = "share.png";
        final imgpath = await File("$directory/$filename").create();
        await imgpath.writeAsBytes(img);

        Share.shareFiles([imgpath.path], text: textController.text);
      } else {
        print("Failed to take a screenshot");
      }
    });
  }

  downloadImg() async {
    var result = await Permission.storage.request();

    if (result.isGranted) {
      const foldername = "AI Image";
      final path = Directory("/storage/emulated/0/Download/$foldername");

      final filename = "${DateTime.now().microsecondsSinceEpoch}.png";

      if (await path.exists()) {
        await screenshotController.captureAndSave(path.path,
            delay: const Duration(milliseconds: 100),
            fileName: filename,
            pixelRatio: 1.0);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Downloaded to ${path.path}")));
      } else {
        await path.create();
        await screenshotController.captureAndSave(path.path,
            delay: const Duration(milliseconds: 100),
            fileName: filename,
            pixelRatio: 1.0);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Downloaded to ${path.path}")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission denied")));
    }
  }

  void loadImage() async {
    if (textController.text.isNotEmpty) {
      setState(() {
        isLoaded = false;
      });

      try {
        image = await Api.generateImage(textController.text);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please Wait! Image is generating...")));
        setState(() {
          isLoaded = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error fetching image. Please try again."),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please pass the query and size")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "AI Image Generator",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8), backgroundColor: btnColor),
              child: Text(
                "My Arts",
                style: TextStyle(color: whiteColor),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ArtScreen()));
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0), // Adjusted vertical padding
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextFormField(
                            controller: textController,
                            decoration: InputDecoration(
                                hintText: 'eg. A white horse',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 44,
                    width: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor, shape: StadiumBorder()),
                      onPressed: () {
                        loadImage();
                      },
                      child: Text(
                        'Generate',
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  isLoaded
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Screenshot(
                                controller: screenshotController,
                                child: Image.network(
                                  image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(8),
                                            backgroundColor: btnColor),
                                        onPressed: () {
                                          downloadImg();
                                        },
                                        icon: Icon(
                                          Icons.download_for_offline_rounded,
                                          color: whiteColor,
                                        ),
                                        label: Text(
                                          'Download',
                                          style: TextStyle(color: whiteColor),
                                        ))),
                                SizedBox(
                                  width: 12,
                                ),
                                ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(8),
                                        backgroundColor: btnColor),
                                    onPressed: () async {
                                      await shareImage();
                                    },
                                    icon: Icon(
                                      Icons.share,
                                      color: whiteColor,
                                    ),
                                    label: Text(
                                      'Share',
                                      style: TextStyle(color: whiteColor),
                                    ))
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/loader.gif'),
                            Text(
                              'Enter prompt for image to be generated...',
                              style:
                                  TextStyle(fontSize: 16.0, color: whiteColor),
                            ),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
