
import 'package:zarelko/database/database.dart';

class FoodWithProductInfo {
  final FoodEntry food;
  final Product product;
  final DateTime? dynamicExpiryDate;

  FoodWithProductInfo({
    required this.food,
    required this.product,
    this.dynamicExpiryDate
  });
}