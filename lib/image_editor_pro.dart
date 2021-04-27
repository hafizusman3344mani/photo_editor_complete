import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ext_storage/ext_storage.dart';
import 'package:firexcode/firexcode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_editor/modules/all_emojies.dart';
import 'package:photo_editor/modules/bottombar_container.dart';
import 'package:photo_editor/modules/emoji.dart';
import 'package:photo_editor/modules/sliders.dart';
import 'package:photo_editor/modules/textview.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
var width = 300;
var height = 300;
bool onPressed1 = false;
bool onPressed2 = false;
bool onPressed3 = false;
bool onPressed4 = false;
bool onPressed5 = false;
List fontsize = [];
// create some values
Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);
var howmuchwidgetis = 0;
List multiwidget = [];
List<Offset> offsets = [];
List type = [];
List colors = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
SignatureController _controller = SignatureController(penColor: Colors.green);

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;

  ImageEditorPro({this.appBarColor, this.bottomBarColor});

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
// ValueChanged<Color> callback
  void changeColor(Color color) {
    pickerColor = color;
    var points = _controller.points;
    _controller = SignatureController(penColor: pickerColor, points: points);
    if (mounted) setState(() {});
  }

  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];

  List aligment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();

  File _image;
  TextEditingController nameController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;

  void timers() {
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction.cancel();

    super.dispose();
  }

  @override
  void initState() {
    timers();
    _controller.clear();
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgetis = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: RepaintBoundary(
          key: globalKey,
          child: xStack.list(
            [
              //Image placed here
              _image != null
                  ? Center(
                      child: Image.file(
                        _image,
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              //Signature placed here
              Signat().xGesture(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox object = context.findRenderObject();
                    var _localPosition =
                        object.globalToLocal(details.globalPosition);
                    _points = List.from(_points)..add(_localPosition);
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _points.add(null);
                },
              ).xContainer(padding: EdgeInsets.all(0.0)),
              xStack.list(
                multiwidget.asMap().entries.map((f) {
                  return type[f.key] == 1
                      //Shape placed here
                      ? EmojiView(
                          left: offsets[f.key].dx,
                          top: offsets[f.key].dy,
                          ontap: () {
                            scaf.currentState.showBottomSheet((context) {
                              return Sliders(
                                textName: 'Shape Size',
                                size: f.key,
                                sizevalue: fontsize[f.key].toDouble(),
                              );
                            });
                          },
                          onpanupdate: (details) {
                            setState(() {
                              offsets[f.key] = Offset(
                                  offsets[f.key].dx + details.delta.dx,
                                  offsets[f.key].dy + details.delta.dy);
                            });
                          },
                          value: f.value,
                          fontsize: fontsize[f.key] * 5.toDouble(),
                          align: Alignment.center,
                          color: colors[f.key],
                        )
                      //Text placed here
                      : TextView(
                          left: offsets[f.key].dx,
                          top: offsets[f.key].dy,
                          ontap: () {
                            scaf.currentState.showBottomSheet((context) {
                              return Sliders(
                                textName: 'Text size',
                                size: f.key,
                                sizevalue: fontsize[f.key].toDouble(),
                              );
                            });
                          },
                          onpanupdate: (details) {
                            setState(() {
                              offsets[f.key] = Offset(
                                  offsets[f.key].dx + details.delta.dx,
                                  offsets[f.key].dy + details.delta.dy);
                            });
                          },
                          value: f.value.toString(),
                          fontsize: fontsize[f.key].toDouble(),
                          color: colors[f.key],
                          align: TextAlign.center,
                        );
                }).toList(),
              )
            ],
          )).xContainer(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
      ),
    ).xCenter().xScaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.transparent,
        key: scaf,
        appBar: AppBar(
          title: Text("Photo Editor"),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          actions: <Widget>[
            'Save'.text().xFlatButton(
                primary: Colors.white,
                onPressed: () {
                  screenshotController
                      .capture(
                          delay: Duration(milliseconds: 500), pixelRatio: 1.5)
                      .then((Uint8List image) async {
                    print("Capture Done");
                    await Permission.storage.request();
                    var status = await Permission.storage.status;
                    final paths =
                        await ExtStorage.getExternalStoragePublicDirectory(
                            ExtStorage.DIRECTORY_DOWNLOADS);
                    if (status.isGranted) {
                      final file = await File(
                              '${paths}/' + DateTime.now().toString() + '.jpg')
                          .create();

                      file.writeAsBytesSync(image);
                      print("adjkasdfksdnfknasdfknkasdfnkasdfnjkasdfn  " +
                          file.path.toString());
                    }
                  }).catchError((onError) {
                    print(onError);
                  });
                })
          ],
          backgroundColor: widget.appBarColor,
        ),

        //Bottom Navigation Bar
        bottomNavigationBar: openbottomsheet
            ? Container()
            : XListView(
                scrollDirection: Axis.horizontal,
              ).list(
                <Widget>[
                  BottomBarContainer(
                    colors: widget.bottomBarColor,
                    icons: Icons.edit_outlined,
                    isPressed: onPressed1,
                    ontap: () {
                      if (onPressed2 || onPressed4) {
                        Navigator.of(context).pop();
                      }
                      // raise the [showDialog] widget
                      onPressed1 = true;
                      onPressed4 = false;
                      onPressed5 = false;
                      onPressed2 = false;
                      onPressed3 = false;
                      showDialog(
                        useRootNavigator: true,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: 'Pick a color!'.text(),
                            content: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ).xSingleChildScroolView(),
                            actions: <Widget>[
                              'Done'.text().xFlatButton(
                                onPressed: () {
                                  setState(() {
                                    currentColor = pickerColor;
                                  });

                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                  BottomBarContainer(
                    icons: Icons.text_format,
                    isPressed: onPressed2,
                    ontap: () {
                      onPressed2 = true;
                      onPressed4 = false;
                      onPressed5 = false;
                      onPressed1 = false;
                      onPressed3 = false;
                      scaf.currentState.showBottomSheet((context) {
                        return TextField(
                          controller: nameController,
                          onSubmitted: (v) {
                            String value = '';
                            Navigator.pop(context);
                            setState(() {
                              nameController.text = '';
                              value = v;
                            });

                            if (value.toString().isEmpty) {
                              print('true');
                            } else {
                              type.add(2);
                              colors.add(currentColor);
                              fontsize.add(20);
                              offsets.add(Offset.zero);
                              multiwidget.add(value);
                              howmuchwidgetis++;
                            }
                          },
                        );
                      });
                    },
                  ),
                  if (_controller.isNotEmpty || multiwidget.length != 0)
                    BottomBarContainer(
                      icons: FontAwesomeIcons.trash,
                      isPressed: onPressed3,
                      ontap: () {
                        onPressed3 = true;
                        onPressed4 = false;
                        onPressed5 = false;
                        onPressed1 = false;
                        onPressed2 = false;

                        if (multiwidget.length != 0) {
                          type.removeLast();
                          multiwidget.removeLast();
                          fontsize.removeLast();
                          offsets.removeLast();
                          colors.removeLast();
                          howmuchwidgetis--;
                        } else {
                          _controller.clear();
                          type.clear();
                          colors.clear();
                          fontsize.clear();
                          offsets.clear();
                          howmuchwidgetis = 0;
                          multiwidget.clear();
                        }
                      },
                    ),
                  BottomBarContainer(
                    icons: FontAwesomeIcons.shapes,
                    isPressed: onPressed4,
                    ontap: () {
                      onPressed4 = true;
                      onPressed1 = false;
                      onPressed5 = false;
                      onPressed2 = false;
                      onPressed3 = false;
                      scaf.currentState.showBottomSheet((context) => Emojies());
                    },
                  ),

                  //for taking image from gallery or camera
                  BottomBarContainer(
                    icons: Icons.camera,
                    isPressed: onPressed5,
                    ontap: () {
                      if (onPressed2 || onPressed4) {
                        Navigator.of(context).pop();
                      }
                      onPressed5 = true;
                      onPressed4 = false;
                      onPressed1 = false;
                      onPressed2 = false;
                      onPressed3 = false;

                      bottomsheets();
                    },
                  ),
                ],
              ).xContainer(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                color: Colors.black,
                height: 70,
              ));
  }

  final picker = ImagePicker();

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    var future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return xColumn.list(
          [
            'Select Image Options'.text().xap(value: 5),
            Divider(
              height: 1,
            ),
            xRowCC.list(
              [
                xColumn.list(
                  [
                    //Getting image from Gallery
                    Icon(Icons.photo_library).xIconButton(onPressed: () async {
                      var image =
                      await picker.getImage(source: ImageSource.gallery);
                      var decodedImage = await decodeImageFromList(
                          File(image.path).readAsBytesSync());

                      setState(() {
                        height = decodedImage.height;
                        width = decodedImage.width;
                        _image = File(image.path);
                      });
                      setState(() => _controller.clear());
                      Navigator.pop(context);
                    }),
                    10.0.sizedWidth(),
                    'Open Gallery'.text()
                  ],
                ).xContainer(
                  onTap: () {},
                ),
                xColumn
                    .list(
                      [
                        //Getting image from camera

                        Icon(Icons.camera_alt).xIconButton(onPressed: () async {
                          var image =
                              await picker.getImage(source: ImageSource.camera);
                          var decodedImage = await decodeImageFromList(
                              File(image.path).readAsBytesSync());

                          setState(() {
                            height = decodedImage.height;
                            width = decodedImage.width;
                            _image = File(image.path);
                          });
                          setState(() => _controller.clear());
                          Navigator.pop(context);
                        }),
                        10.0.sizedWidth(),
                        'Open Camera'.text(),
                      ],
                    )
                    .xContainer(padding: EdgeInsets.all(0.0))
                    .xInkWell(onTap: () {})
              ],
            ).xContainer()
          ],
        ).xContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .25,
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }
}

//For getting signature
class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return xListView.list(
      [
        Signature(
            controller: _controller,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            key: globalKey,
            backgroundColor: Colors.transparent),
      ],
    );
  }
}
