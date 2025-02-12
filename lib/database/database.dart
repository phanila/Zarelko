import 'package:drift/drift.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// import 'package:zarelko/database/DAO/food_response_dao.dart';
part 'database.g.dart';

@DataClassName('FoodEntry')
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get desc => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get expiryDate => dateTime()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, "food_data.sqlite"));
    return NativeDatabase(file);
  });
}
@DriftDatabase(tables: [Foods])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> addFood(FoodsCompanion food) async {
    return await into(foods).insert(food);
  }

  Stream<List<FoodEntry>> foodsInCategory(String? category) {
    if (category == null) {
      return (select(foods)..where((f) => f.category.isNull())).watch();
    } else {
      return (select(foods)..where((f) => f.category.equals(category)))
          .watch();
    }
  }
  // Get all Food
  Stream<List<FoodEntry>> getAllFood() {
    return (select(foods)..where((tbl) => tbl.id.isNotNull())..orderBy([(tbl) => OrderingTerm.asc(tbl.expiryDate)])).watch();
  }

  // Delete a food by id
  Future<int> deleteFoodRecord(int id) async {
    return await (delete(foods)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Update a Food
  // Future<int> updateFoodRecord({required int id, FoodEntry food}) async {
  //   final existingRecord = await (select(foods)..where((tbl) => tbl.id.equals(id))).getSingle();
  //   final newFood = food ?? existingRecord.data;
  //   return await (update(foods)..where((tbl) => tbl.id.equals(id))).write(
  //     food,
  //   );
  // }
}