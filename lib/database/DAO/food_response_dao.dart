// import 'package:drift/drift.dart';
// import 'package:zarelko/database/database.dart';
//
// part 'food__dao.g.dart';  // Generated code
//
// @DriftAccessor(tables: [Foods])
// class FoodsDao extends DatabaseAccessor<AppDatabase> with _$FoodsDaoMixin {
//   FoodsDao(AppDatabase db) : super(db);
//
//   Stream<List<FoodEntry>> foodsInCategory(String? category) {
//     if (category == null) {
//       return (select(foods)..where((f) => isNull(f.category))).watch();
//     } else {
//       return (select(foods)..where((f) => f.category.equals(category)))
//           .watch();
//     }
//   }
//
//   // Insert a new food
//   Future<int> addFood(FoodEntry food) async {
//     return await into(foods).insert(food);
//   }
//   //
//   // Fetch Food
//   Stream<List<FoodEntry>> getAllFood() async {
//     return await (select(foods)..where((tbl) => tbl.id.isNotNull())).get().watch();
//   }
//
//   // Delete a food by id
//   Future<int> deleteFoodRecord(int id) async {
//     return await (delete(foods)..where((tbl) => tbl.id.equals(id))).go();
//   }
//
//   // Update a Food
//   Future<int> updateFoodRecord({required int id, FoodEntry food}) async {
//     final existingRecord = await (select(foods)..where((tbl) => tbl.id.equals(id))).getSingle();
//     final newFood = food ?? existingRecord.data;
//     return await (update(foods)..where((tbl) => tbl.id.equals(id))).write(
//       food,
//     );
//   }
// }