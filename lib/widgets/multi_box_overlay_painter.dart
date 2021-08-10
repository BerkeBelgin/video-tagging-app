import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/models/box_overlay.dart';

class MultiBoxOverlayPainter extends CustomPainter {
	final List<BoxOverlay> boxOverlays;

	MultiBoxOverlayPainter(this.boxOverlays);

	@override
	void paint(Canvas canvas, Size size) {
		for(BoxOverlay boxOverlay in boxOverlays){
			if(boxOverlay.isFull && boxOverlay.color != null){
				Paint paint = Paint();
				paint.style = PaintingStyle.stroke;
				paint.strokeWidth = 2.4;
				paint.color = boxOverlay.color!;
				canvas.drawRect(
					new Rect.fromPoints(
						Offset(size.width * boxOverlay.x1!, size.height * boxOverlay.y1!),
						Offset(size.width * boxOverlay.x2!, size.height * boxOverlay.y2!)
					),
					paint
				);
			}
		}
	}

	@override
	bool shouldRepaint(covariant MultiBoxOverlayPainter oldDelegate){
		return !listEquals(boxOverlays, oldDelegate.boxOverlays);
	}
}