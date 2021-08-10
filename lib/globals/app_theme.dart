import 'package:flutter/material.dart';

class AppTheme {
	static const Color _green = Colors.green;
	static const Color _yellow = Colors.deepOrangeAccent;
	static const Color _black = Color(0xff242424);
	static const Color _grey = Colors.grey;
	static const Color _white = Colors.white;
	static const Color _red = Colors.red;
	static const Color fade = Colors.black38;

	static ThemeData themeData = new ThemeData(
		appBarTheme: AppBarTheme(
			brightness: Brightness.dark,
			color: Colors.transparent,
			iconTheme: IconThemeData(
				color: _white,
			),
			elevation: 0,
		),
		disabledColor: _grey,
		colorScheme: ColorScheme(
			brightness: Brightness.dark,
			primary: _yellow,
			primaryVariant: _yellow,
			secondary: _yellow,
			secondaryVariant: _yellow,
			error: _red,
			surface: _black,
			background: _black,

			onPrimary: _white,
			onSecondary: _white,
			onError: _white,
			onSurface: _white,
			onBackground: _white,
		),
	);

	static const IconData addProject = Icons.add_photo_alternate_rounded;
	static const IconData deleteAll = Icons.delete_rounded;
	static const IconData video = Icons.movie;
	static const IconData videoOutlined = Icons.movie_outlined;
	static const IconData error = Icons.highlight_off_rounded;
	static const IconData searchEmpty = Icons.search_off_rounded;
	static const IconData save = Icons.done;
	static const IconData leftArrow = Icons.arrow_back_ios_rounded;
	static const IconData rightArrow = Icons.arrow_forward_ios_rounded;
	static const IconData addBox = Icons.add_box_outlined;
	static const IconData cancelBox = Icons.close_outlined;
	static const IconData play = Icons.play_arrow;
	static const IconData list = Icons.reorder;
}