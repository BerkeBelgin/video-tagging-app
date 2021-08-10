import 'package:flutter/material.dart';
import 'package:video_editor/globals/app_theme.dart';

class ViewError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
	  return Center(
		  child: Icon(AppTheme.error),
	  );
  }
}