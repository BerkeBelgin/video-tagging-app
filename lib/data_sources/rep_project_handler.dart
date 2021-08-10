import 'package:video_editor/data_sources/ds_project_file_handler.dart';
import 'package:video_editor/data_sources/ds_video_handler.dart';
import 'package:video_editor/models/project_info.dart';

class RepProjectHandler {
	final DSProjectFileHandler _dsProjectFileHandler = new DSProjectFileHandler();
	final DSVideoHandler _dsVideoHandler = new DSVideoHandler();

	Future<ProjectInfo> getProjectInfo(String projectPath) async {
		try {
			String videoPath = await _dsProjectFileHandler.getVideoPath(projectPath);
			Duration videoDuration = await _dsVideoHandler.getVideoDuration(videoPath);
			List<bool> editedParts = await _dsProjectFileHandler.getEditFileExistenceList(videoDuration, projectPath);
			return new ProjectInfo(projectPath, videoPath, videoDuration, editedParts);
		} catch(error){
			return Future.error(error);
		}
	}
}