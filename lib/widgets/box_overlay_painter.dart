import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_theme.dart';
import 'package:video_editor/models/box_overlay.dart';

class BoxOverlayPainter extends CustomPainter {
	final BoxOverlay boxOverlay;

	BoxOverlayPainter(this.boxOverlay);

	bool _equals(BoxOverlayPainter o){
		return (boxOverlay.x1 == o.boxOverlay.x1)
			&& (boxOverlay.y1 == o.boxOverlay.y1)
			&& (boxOverlay.x2 == o.boxOverlay.x2)
			&& (boxOverlay.y2 == o.boxOverlay.y2);
	}

	@override
	void paint(Canvas canvas, Size size) {
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

	@override
	bool shouldRepaint(covariant BoxOverlayPainter oldDelegate) => !this._equals(oldDelegate);
}