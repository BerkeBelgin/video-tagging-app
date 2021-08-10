import 'dart:math';

import 'package:flutter/material.dart';

class RandomColor {
	final List<Color> _colors;
	final Random _rand = new Random();

	RandomColor():
		_colors = [
			Colors.red,
			Colors.blue,
			Colors.green,
			Colors.yellow,
			Colors.orange,
			Colors.purple,
			Colors.pink,
			Colors.cyan,
			Colors.indigo
		];

	RandomColor.fromPool(this._colors);

	Color generateRandom(){
		int idx = _rand.nextInt(_colors.length);
		return _colors[idx];
	}
}