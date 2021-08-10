import 'package:flutter/material.dart';

class AppDialogs {
	static void showLoadingDialog(BuildContext context){
		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				return Center(
					child: CircularProgressIndicator(),
				);
			},
		);
	}
}