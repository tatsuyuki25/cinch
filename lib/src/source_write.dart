class Write {
  String _source;

  Write() : _source = '';

  void write(String s) {
    _source += s;
  }

  void clear() {
    _source = '';
  }

  @override
  String toString() {
    return _source;
  }
}
