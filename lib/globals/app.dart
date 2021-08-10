import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_theme.dart';
import 'package:video_editor/pages/page_project_select.dart';

class App extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Video Editor',
			theme: AppTheme.themeData,
			home: PageProjectSelect(),
			debugShowCheckedModeBanner: false,
		);
	}
}