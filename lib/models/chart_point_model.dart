class ChartPoint {
  final int timestamp;
  final double price;

  ChartPoint({required this.timestamp, required this.price});

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  factory ChartPoint.fromList(List<dynamic> list) {
    int ts = 0;
    double p = 0.0;
    if (list.isNotEmpty) {
      if (list[0] is num) {
        ts = (list[0] as num).toInt();
      }
    }
    if (list.length > 1) {
      if (list[1] is num) {
        p = (list[1] as num).toDouble();
      }
    }
    return ChartPoint(timestamp: ts, price: p);
  }
}
