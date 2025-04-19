import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePciker extends StatefulWidget {
  const UserImagePciker({super.key, required this.onpickimage});

  final void Function(File pickedimage) onpickimage;

  @override
  State<UserImagePciker> createState() => _UserImagePcikerState();
}

class _UserImagePcikerState extends State<UserImagePciker> {
  File? _pickedimagefile;
  void _pickimage() async {
    final pickedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickedimage == null) {
      return;
    }

    setState(() {
      _pickedimagefile = File(pickedimage.path);
    });

    widget.onpickimage(_pickedimagefile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            foregroundImage:
                _pickedimagefile != null ? FileImage(_pickedimagefile!) : null),
        TextButton.icon(
          onPressed: _pickimage,
          label: Text(
            'Add image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          icon: Icon(Icons.image),
        )
      ],
    );
  }
}
