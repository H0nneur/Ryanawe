class StockHistory {
  final String productName;
  final String updatedBy;
  final DateTime updatedAt;
  final int previousStock;
  final int newStock;

  StockHistory({
    required this.productName,
    required this.updatedBy,
    required this.updatedAt,
    required this.previousStock,
    required this.newStock,
  });
}
