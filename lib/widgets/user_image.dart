import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePiker extends StatefulWidget {

  const UserImagePiker({super.key, required this.onpikedImage});
  final  void  Function(File? pikedImage) onpikedImage ;
  @override
  State<UserImagePiker> createState() => _UserImagePikerState();
}

class _UserImagePikerState extends State<UserImagePiker> {
  File? _pikeredImageFile;

  _pikerImage() async {
    final XFile? pikedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 150,
      imageQuality: 50,
    );

    if (pikedImage == null) {
      return;
    }
    setState(() {
      _pikeredImageFile = File(pikedImage.path);
    });

    widget.onpikedImage(_pikeredImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pikeredImageFile == null ? null : FileImage(_pikeredImageFile!) ,
        ),
        TextButton.icon(
          onPressed: _pikerImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
