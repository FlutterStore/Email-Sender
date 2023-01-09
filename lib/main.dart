// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmailSender(),
    );
  }
}

class EmailSender extends StatefulWidget {
  const EmailSender({Key? key}) : super(key: key);

  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  List<String> attachments = [];

  final _recipientController = TextEditingController(
    text: 'example@example.com',
  );

  final _subjectController = TextEditingController(text: 'The subject');

  final _bodyController = TextEditingController(
    text: 'Mail body.',
  );

  Future<void> send() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.withOpacity(0.8),
        action: SnackBarAction(label: "",textColor: Colors.white, onPressed: (){}),
        padding: const EdgeInsets.only(top: 5,left: 8),
        duration: const Duration(seconds: 3),
        content: Text(platformResponse,style: const TextStyle(color: Colors.white,fontSize: 18),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Email Sender',style: TextStyle(fontWeight: FontWeight.normal,fontSize: 15),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: send,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                cursorColor: Colors.green,
                controller: _recipientController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                  focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.green),),
                  labelStyle: TextStyle(fontSize: 15,color: Colors.grey.withOpacity(.8)),
                  labelText: 'Recipient',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                cursorColor: Colors.green,
                controller: _subjectController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                  focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.green),),
                  labelStyle: TextStyle(fontSize: 15,color: Colors.grey.withOpacity(.8)),
                  labelText: 'Subject',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  cursorColor: Colors.green,
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                    focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.green),),
                    labelStyle: TextStyle(fontSize: 15,color: Colors.grey.withOpacity(.8)),
                    labelText: 'Body',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < attachments.length; i++)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            attachments[i],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () => {_removeAttachment(i)},
                        )
                      ],
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _openImagePicker,
                    ),
                  ),
                  TextButton(
                    child: const Text('Attach file in app documents directory'),
                    onPressed: () => _attachFileFromAppDocumentsDirectoy(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePicker() async {
    ImagePicker pick = ImagePicker();
    XFile? profileimage;
    profileimage = await pick.pickImage(source: ImageSource.gallery);
    if (profileimage != null) {
      setState(() {
        attachments.add(profileimage!.path);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<void> _attachFileFromAppDocumentsDirectoy() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path + '/file.txt';
      final file = File(filePath);
      await file.writeAsString('Text file in app directory');

      setState(() {
        attachments.add(filePath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create file in applicion directory'),
        ),
      );
    }
  }
}
