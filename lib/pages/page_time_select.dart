import 'package:flutter/material.dart';
import 'package:video_editor/data_sources/ds_project_file_handler.dart';
import 'package:video_editor/data_sources/rep_project_handler.dart';
import 'package:video_editor/globals/app_router.dart';
import 'package:video_editor/globals/app_text.dart';
import 'package:video_editor/models/project_info.dart';
import 'package:video_editor/widgets/button_video_second.dart';
import 'package:video_editor/widgets/view_error.dart';
import 'package:video_editor/widgets/view_loading.dart';

class PageTimeSelect extends StatefulWidget {
	final String projectPath;

	PageTimeSelect({required this.projectPath});

  @override
  _PageTimeSelectState createState() => _PageTimeSelectState();
}

class _PageTimeSelectState extends State<PageTimeSelect> {
	final DSProjectFileHandler _dsProjectFileHandler = new DSProjectFileHandler();
	final RepProjectHandler _repProjectHandler = new RepProjectHandler();
	late Future<ProjectInfo> _projectInfo;

	String _formatDuration(int seconds){
		return (seconds ~/ 60).toString().padLeft(2, '0') + ':' + (seconds % 60).toString().padLeft(2, '0');
	}

	void _onItemTap(ProjectInfo projectInfo, int index) async {
		await Navigator.push(context, AppRouter.pageVideoEditorRoute(projectInfo, Duration(seconds: index)));
		setState(() {
			_projectInfo = _repProjectHandler.getProjectInfo(widget.projectPath);
		});
	}

	void _onItemLongPress(ProjectInfo projectInfo, int index) async {
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
							Visibility(
								visible: projectInfo.editedParts[index],
								child: ListTile(
									leading: Icon(Icons.delete),
									title: Text('Delete'),
									onTap: () async {
										await _dsProjectFileHandler.deleteEditFile(index, widget.projectPath);
										setState(() {
											projectInfo.editedParts[index] = false;
										});
										Navigator.pop(context);
									},
								)
							),
						],
					),
				);
			}
		);
	}

	Future<ProjectInfo> _onRefresh() {
		setState(() {
			_projectInfo = _repProjectHandler.getProjectInfo(widget.projectPath);
		});
		return _projectInfo;
	}

	@override
	void initState(){
		super.initState();
		_projectInfo = _repProjectHandler.getProjectInfo(widget.projectPath);
	}

	@override
	Widget build(BuildContext context){
		return Scaffold(
			appBar: AppBar(
				title: Text(AppText.seconds_caps),
				centerTitle: true,
			),
			body: LayoutBuilder(
				builder: (BuildContext context, BoxConstraints constraints){
					return FutureBuilder(
						future: _projectInfo,
						builder: (BuildContext context, AsyncSnapshot snapshot){
							return RefreshIndicator(
								onRefresh: _onRefresh,
								child: ((){
									if(snapshot.hasData){
										ProjectInfo projectInfo = snapshot.data;
										return GridView.builder(
											gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
												crossAxisCount: 4,
												childAspectRatio: 1,
											),
											itemCount: projectInfo.videoDuration.inSeconds,
											itemBuilder: (BuildContext context, int index){
												return Padding(
													padding: EdgeInsets.all(6),
													child: ButtonVideoSecond(
														title: _formatDuration(index),
														edited: projectInfo.editedParts[index],
														onTap: () => _onItemTap(projectInfo, index),
														onLongPress: () => _onItemLongPress(projectInfo, index),
													),
												);
											},
										);
									} else if (snapshot.hasError) {
										return SingleChildScrollView(
											physics: AlwaysScrollableScrollPhysics(),
											child: SizedBox(
												height: constraints.maxHeight,
												child: ViewError(),
											)
										);
									} else {
										return SingleChildScrollView(
											physics: AlwaysScrollableScrollPhysics(),
											child: SizedBox(
												height: constraints.maxHeight,
												child: ViewLoading(),
											)
										);
									}
								}()),
							);
						}
					);
				}
			)
		);
	}
}