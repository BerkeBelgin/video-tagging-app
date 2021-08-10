class FilePath {
	final String _path;

	FilePath(this._path);

	static String incrementFileName(String filename){
		if(RegExp(r'^.*? +[(][1-9]\d*[)]$').hasMatch(filename)){
			for(RegExpMatch regExpMatch in RegExp(r'^.*? +[(]([1-9]\d*)[)]$').allMatches(filename).toList()){
				for(RegExpMatch regExpMatch2 in RegExp(r'^(.*? +[(])[1-9]\d*([)])$').allMatches(filename).toList()){
					String? str1 = regExpMatch2.group(1);
					String? str2 = regExpMatch.group(1);
					String? str3 = regExpMatch2.group(2);
					if(str1 != null && str2 != null && str3 != null){
						return str1 + (int.parse(str2) + 1).toString() + str3;
					}
				}
			}
			throw FormatException();
		} else {
			return filename + ' (1)';
		}
	}

	FilePath append(String filename){
		return new FilePath(this._path + '/' + filename);
	}

	String getFileName(){
		return _path.split('/').last.split('.').first;
	}

	String getFileNameWithExtension(){
		return _path.split('/').last;
	}

	String getFileExtension(){
		List<String> strings = _path.split('/').last.split('.');
		if(strings.length > 1) return '.' + strings.last;
		else return '';
	}

	@override
	String toString(){
		return _path;
	}
}