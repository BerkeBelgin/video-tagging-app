import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/models/box_overlay.dart';
import 'package:video_editor/models/project_info.dart';
import 'package:video_editor/widgets/multi_box_overlay_painter.dart';
import 'package:video_player/video_player.dart';

class PageVideoPlayer extends StatefulWidget {
	final ProjectInfo projectInfo;
	final Duration startDuration;
	final Duration duration;
	final List<List<BoxOverlay>>? boxOverlays;

	const PageVideoPlayer({required this.projectInfo, this.boxOverlays, required this.startDuration, required this.duration});

  @override
  _PageVideoPlayerState createState() => _PageVideoPlayerState();
}

class _PageVideoPlayerState extends State<PageVideoPlayer> {
	final StreamController<int> _streamer = StreamController<int>.broadcast();
	late final Timer _timer;
	late final VideoPlayerController _controller;
	// late Future<List<List<BoxOverlay>>> _boxOverlaysFuture;
	late Future<void> _videoPlayerInitialized;
	int _currentBoxOverlayGroupIndex = 0;

	@override
	void initState(){
		_controller = VideoPlayerController.file(File(widget.projectInfo.videoPath));
		// if(widget.boxOverlays == null);
		_videoPlayerInitialized = (() async {
			await _controller.initialize();
			await _controller.seekTo(widget.startDuration);

			_timer = Timer.periodic(Duration(microseconds: 100), (Timer t){
				Duration position = _controller.value.position;
				Duration endDuration = new Duration(microseconds: widget.startDuration.inMicroseconds + widget.duration.inMicroseconds);

				if(position.compareTo(endDuration) >= 0){
					_controller.pause().then((value){
						_controller.seekTo(widget.startDuration).then((value){
							_controller.play();
						});
					});
				} else {
					if(widget.boxOverlays != null){
						int frames = widget.boxOverlays!.length;
						int index = (((position.inMicroseconds - widget.startDuration.inMicroseconds) / widget.duration.inMicroseconds) * frames).toInt();
						if(index != _currentBoxOverlayGroupIndex){
							_streamer.add(index);
							_currentBoxOverlayGroupIndex = index;
						}
					} else {

					}
				}
			});
		}());
		super.initState();
	}

	@override
	void dispose() {
		_controller.dispose();
		_timer.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context){
		return Scaffold(
			appBar: AppBar(
				title: StreamBuilder(
					initialData: _currentBoxOverlayGroupIndex,
					stream: _streamer.stream,
					builder: (BuildContext context, AsyncSnapshot snapshot){
						return Text('${snapshot.data}');
					}
				),
			),
			body: FutureBuilder(
				future: _videoPlayerInitialized,
				builder: (BuildContext context, AsyncSnapshot snapshot) {
					if (snapshot.connectionState == ConnectionState.done) {
						return Center(
							child: Stack(
							  children: [
							    AspectRatio(
							    	aspectRatio: _controller.value.aspectRatio,
							    	child: VideoPlayer(_controller),
							    ),
								  StreamBuilder(
									  initialData: _currentBoxOverlayGroupIndex,
									  stream: _streamer.stream,
									  builder: (BuildContext context, AsyncSnapshot snapshot){
										  List<BoxOverlay> boxOverlays = widget.boxOverlays![snapshot.data];
										  return Positioned.fill(
											  child: CustomPaint(
												  painter: MultiBoxOverlayPainter(boxOverlays),
											  )
										  );
									  }
								  ),
							  ],
							),
						);
					} else {
						return const Center(
							child: CircularProgressIndicator(),
						);
					}
				},
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					setState(() {
						if (_controller.value.isPlaying) {
							_controller.pause();
						} else {
							_controller.play();
						}
					});
				},
				child: Icon(
					_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
				),
			),
		);
	}
}