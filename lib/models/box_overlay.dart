import 'package:flutter/material.dart';

class BoxOverlay {
	double? _x1;
	double? _y1;
	double? _x2;
	double? _y2;
	Color? color;

	BoxOverlay.copy(BoxOverlay o):
		this._x1 = o.x1,
		this._y1 = o.y1,
		this._x2 = o.x2,
		this._y2 = o.y2,
		this.color = o.color;

	BoxOverlay.full(this._x1,this._y1,this._x2,this._y2);
	BoxOverlay.half(this._x1,this._y1);
	BoxOverlay();

	double? get x1 => _x1;
	double? get y1 => _y1;
	double? get x2 => _x2;
	double? get y2 => _y2;

  bool get isFull  => _x1 != null && _y1 != null && _x2 != null && _y2 != null;
	bool get isHalf  => _x1 != null && _y1 != null && _x2 == null && _y2 == null;
	bool get isEmpty => _x1 == null && _y1 == null && _x2 == null && _y2 == null;

  void setFirst(double x, double y){
	  _x1 = x;
	  _y1 = y;
  }

  setSecond(double x, double y){
	  _x2 = x;
	  _y2 = y;
  }

  void reset(){
	  _x1 = null;
	  _y1 = null;
	  _x2 = null;
	  _y2 = null;
	  color = null;
  }

	BoxOverlay.fromMap(Map<String, dynamic> map):
		this._x1 = map['x1'],
		this._y1 = map['y1'],
		this._x2 = map['x2'],
		this._y2 = map['y2'];

	static List<BoxOverlay> listFromMapList(List<dynamic> map) {
		return map.map((o) => BoxOverlay.fromMap(o)).toList();
	}

	static List<List<BoxOverlay>> listListFromMapListList(List<dynamic> map) {
		return map.map((o) => BoxOverlay.listFromMapList(o)).toList();
	}

	Map<String, dynamic> toMap() {
		if(isFull)
			return {
				'x1' : _x1,
				'y1' : _y1,
				'x2' : _x2,
				'y2' : _y2
			};
		else
			throw Exception();
	}

	static List<dynamic> listToMapList(List<BoxOverlay> list) {
		return list.map((BoxOverlay o) => o.toMap()).toList();
	}

	static List<dynamic> listListToMapListList(List<List<BoxOverlay>> list) {
		return list.map((List<BoxOverlay> o) => listToMapList(o)).toList();
	}
}