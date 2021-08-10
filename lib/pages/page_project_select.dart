import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/data_sources/ds_local_video_picker.dart';
import 'package:video_editor/data_sources/ds_project_file_handler.dart';
import 'package:video_editor/globals/app_dialogs.dart';
import 'package:video_editor/globals/app_router.dart';
import 'package:video_editor/globals/app_text.dart';
import 'package:video_editor/globals/app_theme.dart';
import 'package:video_editor/widgets/button_project.dart';
import 'package:video_editor/widgets/view_error.dart';
import 'package:video_editor/widgets/view_loading.dart';
import 'package:video_editor/widgets/view_search_empty.dart';

class PageProjectSelect extends StatefulWidget {
	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PageProjectSelect> {
	final DSLocalVideoPicker _dsLocalVideoPicker = new DSLocalVideoPicker();
	final DSProjectFileHandler _dsProjectHandler = new DSProjectFileHandler();
	late Future<List<String>> _projects;

	void _onItemTap(String projectPath) async {
		await Navigator.push(context, AppRouter.pageTimeSelectRoute(projectPath));
	}

	void _onItemLongPress(String projectPath) async {
		showModalBottomSheet(
			context: context,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(
					top: Radius.circular(16)
				),
			),
			builder: (BuildContext context){
				return Padding(
					padding: EdgeInsets.symmetric(vertical: 12),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							ListTile(
								leading: Icon(Icons.delete),
								title: Text('Delete'),
								onTap: () async {
									await _dsProjectHandler.deleteProject(projectPath);
									setState(() {
										_projects = _dsProjectHandler.getProjects();
									});
									Navigator.pop(context);
								},
							),
						],
					),
				);
			}
		);
	}
	
	void _addProject() async {
		AppDialogs.showLoadingDialog(context);
		try {
			File video = await _dsLocalVideoPicker.pickVideo();
			await _dsProjectHandler.createProject(video);
		} catch(_) {

		}
		Navigator.pop(context);

		setState(() {
			_projects = _dsProjectHandler.getProjects();
		});
	}

	void _clearAllProjects() async {
		await _dsProjectHandler.clearAllProjects();
		setState(() {
			_projects = _dsProjectHandler.getProjects();
		});
	}

	Future<List<String>> _onRefresh() {
		setState(() {
			_projects = _dsProjectHandler.getProjects();
		});
		return _projects;
	}

	@override
	void initState(){
		super.initState();
		_projects = _dsProjectHandler.getProjects();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(AppText.videos_caps),
				centerTitle: true,
				actions: [
					IconButton(
						icon: Icon(AppTheme.addProject),
						onPressed: _addProject
					),
					IconButton(
						icon: Icon(AppTheme.deleteAll),
						onPressed: _clearAllProjects
					),
				],
			),
			body: LayoutBuilder(
				builder: (BuildContext context, BoxConstraints constraints){
					return FutureBuilder(
						future: _projects,
						builder: (BuildContext context, AsyncSnapshot snapshot) {
							if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
								List<String> projects = snapshot.data;
								return RefreshIndicator(
									onRefresh: _onRefresh,
									child: projects.isNotEmpty ? GridView.builder(
										gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
											crossAxisCount: 2,
											childAspectRatio: 1,
										),
										itemCount: projects.length,
										itemBuilder: (BuildContext context, int index){
											return Padding(
												padding: EdgeInsets.all(6),
												child: ButtonProject(
													title: AppText.video + ' ' + (index + 1).toString(),
													onTap: () => _onItemTap(projects[index]),
													onLongPress: () => _onItemLongPress(projects[index]),
												),
											);
										},
									) : SingleChildScrollView(
										physics: AlwaysScrollableScrollPhysics(),
										child: SizedBox(
											height: constraints.maxHeight,
											child: ViewSearchEmpty(),
										)
									),
								);
							} else if (snapshot.connectionState != ConnectionState.done) {
								return ViewLoading();
							} else {
								return ViewError();
							}
						},
					);
				},
			),
		);
	}
}
