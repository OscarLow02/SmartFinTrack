class StatisticsService {
  // Calculate total spending per category
  static Map<String, double> calculateCategoryTotals(
      List<Map<String, dynamic>> transactions) {
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      String category = transaction['category'];
      double amount = transaction['amount'];

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }
    return categoryTotals;
  }

  // Convert totals into percentages
  static Map<String, int> calculatePercentages(
      Map<String, double> categoryTotals) {
    double totalAmount =
        categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    Map<String, int> percentages = {};

    if (totalAmount > 0) {
      categoryTotals.forEach((category, amount) {
        double percentage = (amount / totalAmount) * 100;
        percentages[category] = percentage.round(); // Round to integer
      });
    }

    return percentages;
  }

  // Process transactions into time-series data for the line graph
  static Map<String, double> calculateTimeSeriesData(
      List<Map<String, dynamic>> transactions, String period) {
    Map<String, double> timeSeriesData = {};

    for (var transaction in transactions) {
      String key = period == "Monthly"
          ? transaction['dateTime']
              .substring(8, 10) // Extract day for monthly view
          : transaction['dateTime']
              .substring(5, 7); // Extract month for yearly view

      double amount = transaction['amount'];

      if (timeSeriesData.containsKey(key)) {
        timeSeriesData[key] = timeSeriesData[key]! + amount;
      } else {
        timeSeriesData[key] = amount;
      }
    }

    // Ensure the data is sorted
    return Map.fromEntries(timeSeriesData.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key))));
  }
}
