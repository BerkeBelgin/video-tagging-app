import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_text.dart';
import 'package:video_editor/globals/app_theme.dart';

class ViewSearchEmpty extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Center(
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Icon(
						AppTheme.searchEmpty,
					),
					SizedBox(
						height: 4,
					),
					Text(
						AppText.searchEmpty,
					)
				],
			),
		);
	}
}