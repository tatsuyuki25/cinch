///內含兩個資料
class Pair<F, S> {
  const Pair(this.first, this.second);

  final F first;
  final S second;
}


///內含三個資料
class Tirple<F, S, T> {
  const Tirple(this.first, this.second, this.third);

  final F first;
  final S second;
  final T third;
}

/// 動態設定URL
mixin ApiUrlMixin {

  String get url;
}