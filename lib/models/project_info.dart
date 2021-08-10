class ProjectInfo {
	final String _projectPath;
	final String _videoPath;
	final Duration _videoDuration;
	final List<bool> _editedParts;

	ProjectInfo(this._projectPath, this._videoPath, this._videoDuration, this._editedParts);

	List<bool> get editedParts => _editedParts;
	String get videoPath => _videoPath;
  Duration get videoDuration => _videoDuration;
  String get projectPath => _projectPath;
}