class StatisticsService {
  // Calculate total spending per category
  static Map<String, double> calculateCategoryTotals(
      Map<String, Map<String, dynamic>> transactions) {
    Map<String, double> categoryTotals = {};
    transactions.forEach((key, transaction) {
      // Extract the category and amount from each transaction
      String category = transaction['category'] as String;
      double amount = transaction['amount'] as double;

      // Sum the amounts per category
      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    });
    return categoryTotals;
  }

  // Convert totals into percentages
  static Map<String, int> calculatePercentages(
      Map<String, Map<String, dynamic>> transactions) {
    // First, compute the totals per category
    Map<String, double> categoryTotals = calculateCategoryTotals(transactions);
    // Compute the overall total
    double totalAmount =
        categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    Map<String, int> percentages = {};

    if (totalAmount > 0) {
      categoryTotals.forEach((category, amount) {
        // Calculate the percentage share for each category
        double percentage = (amount / totalAmount) * 100;
        percentages[category] = percentage.round();
      });
    }

    return percentages;
  }
}
