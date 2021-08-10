import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/models/file_path.dart';

class DSVideoHandler {
	static const _cacheDirectoryName = 'cache';

	final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
	final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

	int _fileComparator(File a, File b){
		int aName = int.parse(new FilePath(a.path).getFileName());
		int bName = int.parse(new FilePath(b.path).getFileName());
		return aName.compareTo(bName);
	}

	Future<Duration> getVideoDuration(String videoPath) async {
		return _flutterFFprobe.getMediaInformation(videoPath).then((MediaInformation info){
			Map<dynamic, dynamic>? infoMap = info.getMediaProperties();
			if(infoMap != null){
				String durationStr = infoMap['duration'];
				return new Duration(seconds: double.parse(durationStr).toInt());
			} else {
				throw FileSystemException();
			}
		});
	}

	Future<List<File>> getVideoFramesOneSec(String videoPath, Duration startSec, Duration duration) async {
		String startSecFormatted = startSec.toString().split('.').first;
		String durationFormatted = duration.toString().split('.').first;

		try {
			Directory appDocDir = await getApplicationDocumentsDirectory();
			Directory cacheDir = Directory(new FilePath(appDocDir.path).append(_cacheDirectoryName).toString());
			if(await cacheDir.exists()){
				List<FileSystemEntity> fileSystemEntities = await cacheDir.list().toList();
				for(FileSystemEntity fileSystemEntity in fileSystemEntities){
					await fileSystemEntity.delete(recursive: true);
				}
			} else {
				await cacheDir.create();
			}
			String outputPath = new FilePath(cacheDir.path).append('%d.png').toString();
			int response = await _flutterFFmpeg.execute('-i $videoPath -ss $startSecFormatted -t $durationFormatted $outputPath');
			if(response == 0){
				List<File> files = [];

				List<FileSystemEntity> fileSystemEntities = await cacheDir.list().toList();
				if(fileSystemEntities.isNotEmpty){
					for(FileSystemEntity fileSystemEntity in fileSystemEntities){
						File file = new File(fileSystemEntity.path);
						files.add(file);
					}
					files.sort(_fileComparator);

					return files;
				} else {
					throw Exception();
				}
			} else {
				throw Exception();
			}
		} catch(error) {
			throw Exception(error);
		}
	}

	Future<void> clearCache() async {
		try {
			Directory appDocDir = await getApplicationDocumentsDirectory();
			Directory cacheDir = Directory(new FilePath(appDocDir.path).append(_cacheDirectoryName).toString());
			if(await cacheDir.exists()){
				List<FileSystemEntity> fileSystemEntities = await cacheDir.list().toList();
				for(FileSystemEntity fileSystemEntity in fileSystemEntities){
					await fileSystemEntity.delete(recursive: true);
				}
			}
		} catch(error) {
			throw Exception(error);
		}
	}
}