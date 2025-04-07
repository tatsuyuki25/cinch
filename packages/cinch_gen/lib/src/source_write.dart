/// 原始碼寫入器
class Write {
  Write() : _source = '';

  /// 原始碼
  String _source;

  /// 寫入[s]
  void write(String s) {
    _source += s;
  }

  /// 清空原始碼
  void clear() {
    _source = '';
  }

  @override
  String toString() {
    return _source;
  }
}
