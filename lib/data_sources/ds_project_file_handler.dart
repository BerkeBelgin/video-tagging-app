import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_editor/models/box_overlay.dart';
import 'package:video_editor/models/file_path.dart';

class DSProjectFileHandler {
	static const _videoFileName = 'video';
	static const _projectDirectoryName = 'projects';
	static const _editFileHeader = 'edit_';

	bool _isEditFile(String filename){
		return RegExp(r'^edit_[0-9]+$').hasMatch(filename);
	}

	int _getEditFileIndex(String filename){
		for(RegExpMatch regExpMatch in RegExp(r'^edit_([0-9]+)$').allMatches(filename).toList()){
			String? str = regExpMatch.group(1);
			if(str != null){
				return int.parse(str);
			}
		}
		throw FileSystemException();
	}

	Future<List<bool>> getEditFileExistenceList(Duration videoDuration, String projectPath) async {
		List<bool> result = List.filled(videoDuration.inSeconds, false);

		Directory projDir = new Directory(projectPath);
		try {
			bool exists = await projDir.exists();
			if(exists){
				List<FileSystemEntity> fileSystemEntities = await projDir.list().toList();
				for(FileSystemEntity fileSystemEntity in fileSystemEntities){
					String filename = new FilePath(fileSystemEntity.path).getFileName();
					if(_isEditFile(filename)){
						result[_getEditFileIndex(filename)] = true;
					}
				}
				return result;
			} else {
				throw FileSystemException();
			}
		} catch(error) {
			throw Exception(error);
		}
	}

	Future<bool> editFileExists(int index, String projectPath) async {
		FilePath filePath = new FilePath(projectPath).append('$_editFileHeader$index');
		return new File(filePath.toString()).exists();
	}

	Future<List<List<BoxOverlay>>> readEditFile(int index, String projectPath) async {
		FilePath filePath = new FilePath(projectPath).append('$_editFileHeader$index');
		File editFile = new File(filePath.toString());
		try {
			if(await editFile.exists()){
				String content = await editFile.readAsString();
				print(content);
				return BoxOverlay.listListFromMapListList(json.decode(content));
			} else {
				throw FileSystemException();
			}
		} catch(error) {
			throw Exception(error);
		}
	}

	// Future<List<List<BoxOverlay>>> readAllEditFiles(String projectPath) async {
	// 	List<bool> result = List.filled(videoDuration.inSeconds, false);
	//
	// 	Directory projDir = new Directory(projectPath);
	// 	try {
	// 		bool exists = await projDir.exists();
	// 		if(exists){
	// 			List<FileSystemEntity> fileSystemEntities = await projDir.list().toList();
	// 			for(FileSystemEntity fileSystemEntity in fileSystemEntities){
	// 				String filename = new FilePath(fileSystemEntity.path).getFileName();
	// 				if(_isEditFile(filename)){
	// 					result[_getEditFileIndex(filename)] = true;
	// 				}
	// 			}
	// 			return result;
	// 		} else {
	// 			throw FileSystemException();
	// 		}
	// 	} catch(error) {
	// 		throw Exception(error);
	// 	}
	// }

	Future<void> saveEditFile(List<List<BoxOverlay>> boxOverlays, int index, String projectPath) async {
		FilePath filePath = new FilePath(projectPath).append('$_editFileHeader$index');
		File editFile = new File(filePath.toString());
		try {
			String content = json.encode(BoxOverlay.listListToMapListList(boxOverlays));
			editFile = await editFile.writeAsString(content);
		} catch(error) {
			throw Exception(error);
		}
	}

	Future<void> deleteEditFile(int index, String projectPath) async {
		FilePath filePath = new FilePath(projectPath).append('$_editFileHeader$index');
		await new File(filePath.toString()).delete();
	}

	bool _filenameCollisionExists(String filename, List<FileSystemEntity> fileSystemEntities){
		for(FileSystemEntity fileSystemEntity in fileSystemEntities){
			if(new FilePath(fileSystemEntity.path).getFileName() == filename) return true;
		}
		return false;
	}

	Future<void> createProject(File video) async {
		if(await video.exists()){
			getApplicationDocumentsDirectory().then((Directory appDocDir) async {
				Directory projectsDir = Directory(new FilePath(appDocDir.path).append(_projectDirectoryName).toString());
				await projectsDir.create();
				String projDirName = new FilePath(video.path).getFileName();
				projectsDir.list().toList().then((List<FileSystemEntity> fileSystemEntities){
					while(_filenameCollisionExists(projDirName, fileSystemEntities)){
						projDirName = FilePath.incrementFileName(projDirName);
					}
				}).onError((error, stackTrace){
					throw FileSystemException();
				});

				Directory projDir = new Directory(new FilePath(projectsDir.path).append(projDirName).toString());

				projDir.create().then((value) async {
					await video.copy(new FilePath(projDir.path).append(_videoFileName).toString() + new FilePath(video.path).getFileExtension());
				}).onError((error, stackTrace){
					throw FileSystemException();
				});
			}).onError((error, stackTrace){
				throw FileSystemException();
			});
		} else throw FileSystemException();
	}

	Future<void> deleteProject(String projectPath) async {
		Directory dir = new Directory(projectPath);
		return dir.exists().then((bool exists){
			if(exists){
				dir.delete(recursive: true);
			} else {
				throw FileSystemException();
			}
		}).onError((error, stackTrace){
			throw FileSystemException();
		});
	}

	Future<void> clearAllProjects(){
		return getApplicationDocumentsDirectory().then((Directory appDocDir) async {
			Directory projectsDir = Directory(new FilePath(appDocDir.path).append(_projectDirectoryName).toString());
			if(await projectsDir.exists()){
				return projectsDir.list().toList().then((List<FileSystemEntity> fileSystemEntities) async {
					for(FileSystemEntity fileSystemEntity in fileSystemEntities){
						await fileSystemEntity.delete(recursive: true);
					}
					return;
				}).onError((error, stackTrace){
					throw FileSystemException();
				});
			}
		}).onError((error, stackTrace){
			throw FileSystemException();
		});
	}

	Future<List<String>> getProjects() async {
		List<String> projectNames = [];
		return getApplicationDocumentsDirectory().then((Directory appDocDir) async {
			Directory projectsDir = Directory(new FilePath(appDocDir.path).append(_projectDirectoryName).toString());
			if(await projectsDir.exists()){
				return projectsDir.list().toList().then((List<FileSystemEntity> fileSystemEntities) async {
					for(FileSystemEntity fileSystemEntity in fileSystemEntities){
						if((await fileSystemEntity.stat()).type == FileSystemEntityType.directory){
							projectNames.add(fileSystemEntity.path);
						}
					}
					return projectNames;
				}).onError((error, stackTrace){
					throw FileSystemException();
				});
			} else {
				return projectNames;
			}
		}).onError((error, stackTrace){
			throw FileSystemException();
		});
	}

	Future<String> getVideoPath(String projectPath) async {
		Directory dir = new Directory(projectPath);
		return dir.list().toList().then((List<FileSystemEntity> fileSystemEntities){
			for(FileSystemEntity fileSystemEntity in fileSystemEntities){
				if(new FilePath(fileSystemEntity.path).getFileName() == _videoFileName){
					return fileSystemEntity.path;
				}
			}
			throw FileSystemException();
		}).onError((error, stackTrace){
			throw FileSystemException();
		});
	}
}
