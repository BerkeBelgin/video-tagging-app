import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_theme.dart';

class ButtonVideoSecond extends StatelessWidget {
	final String title;
	final bool edited;
	final Function()? onTap;
	final Function()? onLongPress;

	ButtonVideoSecond({this.title = '', this.edited = false, this.onTap, this.onLongPress});

	@override
	Widget build(BuildContext context){
		return Column(
			children: [
				Expanded(
					child: Padding(
						padding: EdgeInsets.all(8),
						child: AspectRatio(
							aspectRatio: 1,
							child: InkWell(
								borderRadius: BorderRadius.circular(12),
								onTap: onTap,
								onLongPress: onLongPress,
								child: Ink(
									decoration: BoxDecoration(
										color: edited ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary,
										borderRadius: BorderRadius.circular(12),
									),
									child: Center(
										child: Icon(
											edited ? Icons.done : AppTheme.videoOutlined,
											size: 24,
										),
									),
								),
							),
						),
					),
				),
				Text(title),
			],
		);
	}
}