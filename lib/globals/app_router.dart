import 'package:flutter/material.dart';
import 'package:video_editor/models/box_overlay.dart';
import 'package:video_editor/models/project_info.dart';
import 'package:video_editor/pages/page_project_select.dart';
import 'package:video_editor/pages/page_time_select.dart';
import 'package:video_editor/pages/page_video_editor.dart';
import 'package:video_editor/pages/page_video_player.dart';

class AppRouter {
	static MaterialPageRoute pageProjectSelectRoute() => MaterialPageRoute(
		builder: (_) => PageProjectSelect()
	);
	static MaterialPageRoute pageTimeSelectRoute(String projectPath) => MaterialPageRoute(
		builder: (_) => PageTimeSelect(projectPath: projectPath)
	);
	static MaterialPageRoute pageVideoEditorRoute(ProjectInfo projectInfo, Duration startDuration) => MaterialPageRoute(
		builder: (_) => PageVideoEditor(projectInfo: projectInfo, startDuration: startDuration)
	);
	static MaterialPageRoute pageVideoPlayerRoute(ProjectInfo projectInfo, List<List<BoxOverlay>> boxOverlays, Duration startDuration, Duration duration) => MaterialPageRoute(
		builder: (_) => PageVideoPlayer(projectInfo: projectInfo, boxOverlays: boxOverlays, startDuration: startDuration, duration: duration)
	);
}