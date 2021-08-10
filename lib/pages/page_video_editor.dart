import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/data_sources/ds_project_file_handler.dart';
import 'package:video_editor/data_sources/ds_video_handler.dart';
import 'package:video_editor/globals/app_router.dart';
import 'package:video_editor/globals/app_theme.dart';
import 'package:video_editor/models/box_overlay.dart';
import 'package:video_editor/models/project_info.dart';
import 'package:video_editor/models/random_color.dart';
import 'package:video_editor/widgets/box_overlay_painter.dart';
import 'package:video_editor/widgets/multi_box_overlay_painter.dart';
import 'package:video_editor/widgets/view_error.dart';
import 'package:video_editor/widgets/view_loading.dart';

class PageVideoEditor extends StatefulWidget {
	final ProjectInfo projectInfo;
	final Duration startDuration;

  const PageVideoEditor({required this.projectInfo, required this.startDuration});

  @override
  _PageVideoEditorState createState() => _PageVideoEditorState();
}

class _PageVideoEditorState extends State<PageVideoEditor> {
	final PageController _controller = new PageController();
	final DSVideoHandler _dsVideoHandler = new DSVideoHandler();
	final DSProjectFileHandler _dsProjectFileHandler = new DSProjectFileHandler();
	final RandomColor _randomColor = new RandomColor();

	late Future<List<File>> _images;
	late Future<List<List<BoxOverlay>>> _boxOverlays;

	final BoxOverlay _boxOverlay = new BoxOverlay();

	int _frameCount = 0;
	int _frameIndex = 0;
	bool _finished = false;
	bool _editEnabled = false;

	void _onPageChanged(int index){
		setState(() {
			_frameIndex = index + 1;
			_finished = _finished || _frameIndex == _frameCount;
		});
	}

	void _onRightArrowPressed(){
		_controller.nextPage(duration: new Duration(milliseconds: 500), curve: new ElasticOutCurve(2));
		setState(() {
			_editEnabled = false;
		});
	}

	void _onLeftArrowPressed(){
		_controller.previousPage(duration: new Duration(milliseconds: 500), curve: new ElasticOutCurve(2));
		setState(() {
			_editEnabled = false;
		});
	}

	void _onAddBoxPressed(){
		setState(() {
			_boxOverlay.reset();
			_boxOverlay.color = _randomColor.generateRandom();
			_editEnabled = true;
		});
	}

	void _onCancelBoxPressed(){
		setState(() {
			_boxOverlay.reset();
			_editEnabled = false;
		});
	}

	void _onPlayPressed(List<List<BoxOverlay>> boxOverlays) async {
		await Navigator.push(context, AppRouter.pageVideoPlayerRoute(widget.projectInfo, boxOverlays, widget.startDuration, new Duration(seconds: 1)));
	}

	void _onSavePressed(List<List<BoxOverlay>> boxOverlays) async {
		await _dsProjectFileHandler.saveEditFile(boxOverlays, widget.startDuration.inSeconds, widget.projectInfo.projectPath);
		Navigator.pop(context);
	}

	void _onPanDown(DragDownDetails dragDownDetails, BoxConstraints constraints){
		_boxOverlay.setFirst(
			dragDownDetails.localPosition.dx / constraints.maxWidth,
			dragDownDetails.localPosition.dy / constraints.maxHeight
		);
	}

	void _onPanStart(DragStartDetails dragStartDetails, BoxConstraints constraints){
		setState(() {});
	}

	void _onPanUpdate(DragUpdateDetails dragUpdateDetails, BoxConstraints constraints){
		setState(() {
			double x = dragUpdateDetails.localPosition.dx / constraints.maxWidth;
			double y = dragUpdateDetails.localPosition.dy / constraints.maxHeight;

			if(x < 0)x = 0;
			else if(x > 1)x = 1;
			if(y < 0)y = 0;
			else if(y > 1)y = 1;

			_boxOverlay.setSecond(x,y);
		});
	}

	void _onPanEnd(DragEndDetails dragEndDetails, BoxConstraints constraints, List<List<BoxOverlay>> boxOverlays, int index){
		setState(() {
			boxOverlays[index].add(new BoxOverlay.copy(_boxOverlay));
			_boxOverlay.reset();
			_editEnabled = false;
		});
	}

	@override
	void initState(){
		super.initState();
		_images = _dsVideoHandler.getVideoFramesOneSec(widget.projectInfo.videoPath, widget.startDuration, new Duration(seconds: 1));
		_boxOverlays = _dsProjectFileHandler.readEditFile(widget.startDuration.inSeconds, widget.projectInfo.projectPath);
		_images.then((List<File> files) async {
			_boxOverlays.onError((error, stackTrace){
					_boxOverlays = Future<List<List<BoxOverlay>>>.value(new List.generate(files.length, (int index) => <BoxOverlay>[]));
					return _boxOverlays;
			});
			setState(() {
				_frameCount = files.length;
				_frameIndex = 1;
			});
		});
		_boxOverlays.then((List<List<BoxOverlay>> boxOverlays){
			setState(() {
				for(List<BoxOverlay> boxOverlayGroup in boxOverlays){
					for(BoxOverlay boxOverlay in boxOverlayGroup){
						boxOverlay.color = _randomColor.generateRandom();
					}
				}
			});
		});
	}

	@override
	void dispose(){
		super.dispose();
	}

	@override
	Widget build(BuildContext context){
		return FutureBuilder(
			future: _images,
			builder: (BuildContext context, AsyncSnapshot imagesSnapshot) {
				return FutureBuilder(
					future: _boxOverlays,
					builder: (BuildContext context, AsyncSnapshot overlaysSnapshot){
						return Scaffold(
							appBar: AppBar(
								leading: !_editEnabled ? null : IconButton(
									onPressed: _onCancelBoxPressed,
									icon: Icon(AppTheme.cancelBox)
								),
								centerTitle: true,
								title: Row(
									mainAxisSize: MainAxisSize.max,
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
										Visibility(
											visible: !_editEnabled && imagesSnapshot.hasData && overlaysSnapshot.hasData,
											child: IconButton(
												onPressed: () => _onPlayPressed(overlaysSnapshot.data),
												icon: Icon(AppTheme.play)
											)
										),
										Visibility(
											visible: !_editEnabled && imagesSnapshot.hasData && overlaysSnapshot.hasData,
											child: IconButton(
												onPressed: _onAddBoxPressed,
												icon: Icon(AppTheme.addBox)
											),
										)
									],
								),
								actions: [
									Visibility(
										visible: !_editEnabled && imagesSnapshot.hasData && overlaysSnapshot.hasData,
										child: IconButton(
											onPressed: _finished ? () => _onSavePressed(overlaysSnapshot.data) : null,
											icon: Icon(AppTheme.save)
										)
									),

								],
							),
							bottomNavigationBar: BottomAppBar(
								child: Row(
									mainAxisSize: MainAxisSize.max,
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
										Visibility(
											visible: (imagesSnapshot.hasData && overlaysSnapshot.hasData),
											maintainState: true,
											maintainAnimation: true,
											maintainSize: true,
											child: IconButton(
												onPressed: _onLeftArrowPressed,
												icon: Icon(AppTheme.leftArrow)
											)
										),
										Text('$_frameIndex/$_frameCount'),
										Visibility(
											visible: (imagesSnapshot.hasData && overlaysSnapshot.hasData),
											maintainState: true,
											maintainAnimation: true,
											maintainSize: true,
											child: IconButton(
												onPressed: _onRightArrowPressed,
												icon: Icon(AppTheme.rightArrow)
											)
										),
									],
								),
							),
							body: ((){
								if(imagesSnapshot.hasData && overlaysSnapshot.hasData){
									List<File> files = imagesSnapshot.data;
									List<List<BoxOverlay>> boxOverlays = overlaysSnapshot.data;

									return PageView.builder(
										controller: _controller,
										physics: NeverScrollableScrollPhysics(),
										itemCount: _frameCount,
										onPageChanged: _onPageChanged,
										itemBuilder: (BuildContext context, int index){
											return InteractiveViewer(
												panEnabled: !_editEnabled,
												scaleEnabled: !_editEnabled,
												minScale: 1,
												maxScale: 2,
												// boundaryMargin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
												child: Center(
													child: Stack(
														children: [
															Image.file(files[index]),
															Positioned.fill(
																child: CustomPaint(
																	painter: MultiBoxOverlayPainter(boxOverlays[index]),
																)
															),
															Positioned.fill(
																child: CustomPaint(
																	painter: BoxOverlayPainter(_boxOverlay),
																)
															),
															Visibility(
																visible: _editEnabled,
																child: Positioned.fill(
																	child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
																		return GestureDetector(
																			onPanDown: (DragDownDetails dragDownDetails) => _onPanDown(dragDownDetails, constraints),
																			onPanStart: (DragStartDetails dragStartDetails) => _onPanStart(dragStartDetails, constraints),
																			onPanUpdate: (DragUpdateDetails dragUpdateDetails) => _onPanUpdate(dragUpdateDetails, constraints),
																			onPanEnd: (DragEndDetails dragEndDetails) => _onPanEnd(dragEndDetails, constraints, boxOverlays, index),
																			child: Container(
																				color: AppTheme.fade,
																			),
																		);
																	})
																),
															),
														],
													),
												),
											);
										}
									);
								} else if (imagesSnapshot.hasError) {
									return ViewError();
								} else {
									return ViewLoading();
								}
							}()),
						);
					},
				);
			}
		);
	}
}
