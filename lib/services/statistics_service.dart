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

  Future<Map<String, double>> calculateTotal({
    required Map<String, Map<String, dynamic>> transactions,
    required DateTime selectedDate,
    required String viewMode,
  }) async {
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    // 1. Determine date boundaries based on viewMode
    DateTime startDate;
    DateTime endDate;
    if (viewMode == "Monthly") {
      startDate = DateTime(selectedDate.year, selectedDate.month, 1);
      endDate = (selectedDate.month < 12)
          ? DateTime(selectedDate.year, selectedDate.month + 1, 1)
          : DateTime(selectedDate.year + 1, 1, 1);
    } else {
      // Yearly view
      startDate = DateTime(selectedDate.year, 1, 1);
      endDate = DateTime(selectedDate.year + 1, 1, 1);
    }

    // 2. Helper to parse the transaction's dateTime string.
    DateTime? parseTransactionDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print("Error parsing dateString '$dateString': $e");
        return null;
      }
    }

    // 3. Iterate through all transactions
    for (var txn in transactions.values) {
      DateTime? txnDate = parseTransactionDate(txn['dateTime']);
      if (txnDate == null) continue;

      // Check if transaction date is in the defined period [startDate, endDate)
      bool inRange = (txnDate.isAtSameMomentAs(startDate) ||
          (txnDate.isAfter(startDate) && txnDate.isBefore(endDate)));
      if (!inRange) continue;

      // Get the transaction amount.
      double amount =
          (txn['amount'] is num) ? (txn['amount'] as num).toDouble() : 0.0;

      // Sum based on transaction type.
      String type = (txn['type'] ?? "").toString().toLowerCase();
      if (type == "income") {
        totalIncome += amount;
      } else if (type == "expense") {
        totalExpenses += amount;
      }
    }

    return {
      "income": totalIncome,
      "expenses": totalExpenses,
    };
  }
}
