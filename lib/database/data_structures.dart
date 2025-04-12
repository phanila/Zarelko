import 'package:zarelko/database/database.dart';

class FoodWithProductInfo {
  final FoodEntry food;
  final Product product;
  final DateTime finalDate;
  final String finalPlace;

  FoodWithProductInfo({
    required this.food,
    required this.product}): finalDate = _computeFinalDate(food, product),finalPlace = _computeFinalPlace(food, product);

  // Private method to compute finalDate
  static DateTime _computeFinalDate(FoodEntry food, Product product) {
    if (food.openingDate == null) {
      return food.expiryDate;
    }
    else {
      DateTime afterOpeningDate = food.openingDate!.add(Duration(days: product.openLife));
      return food.expiryDate.isBefore(afterOpeningDate) ? food.expiryDate: afterOpeningDate;
    }
  }

  static _computeFinalPlace(FoodEntry food, Product product) {
    return food.openingDate == null || product.openLocation == ""? product.storingLocation: product.openLocation;
  }
}
class FoodWithPlace {
  final FoodEntry food;

  FoodWithPlace(this.food);
}