import 'dart:io';

import 'package:image_picker/image_picker.dart';

class DSLocalVideoPicker {
	Future<File> pickVideo() async {
		ImagePicker imagePicker = new ImagePicker();
		XFile? xFile = await imagePicker.pickVideo(source: ImageSource.gallery);
		if(xFile != null){
			print(xFile.name);
			File file = new File(xFile.path);
			if(await file.exists()){
				return file;
			} else {
				throw FileSystemException();
			}
		} else {
			throw FileSystemException();
		}
	}
}
