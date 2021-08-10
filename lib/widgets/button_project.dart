import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_theme.dart';

class ButtonProject extends StatelessWidget {
	final String title;
	final Function()? onTap;
	final Function()? onLongPress;

	ButtonProject({this.title = '', this.onTap, this.onLongPress});

	@override
	Widget build(BuildContext context){
		return Column(
			children: [
				Padding(
					padding: EdgeInsets.all(8),
					child: InkWell(
						borderRadius: BorderRadius.circular(20),
						onTap: onTap,
						onLongPress: onLongPress,
						child: Ink(
							width: 80,
							height: 80,
							decoration: BoxDecoration(
								color: Theme.of(context).colorScheme.primary,
								borderRadius: BorderRadius.circular(20),
							),
							child: Center(
								child: Icon(
									AppTheme.video,
									size: 32,
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