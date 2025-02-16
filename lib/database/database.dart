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
  TextColumn get name => text().references(Products, #name)();
  TextColumn get desc => text().nullable()();
  DateTimeColumn get expiryDate => dateTime()();
  DateTimeColumn get openingDate => dateTime().nullable()();
  IntColumn get amount => integer().nullable()();
}
@DataClassName('Product')
class Products extends Table {
  TextColumn get name => text()();
  IntColumn get openLife => integer()();
  TextColumn get storingLocation => text().nullable()();
  TextColumn get openLocation => text().nullable()();
  TextColumn get unit => text().nullable()();
  IntColumn get basicAmount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
@DataClassName('ProductCategory')
class ProductCategories extends Table {
  TextColumn get product => text().references(Products, #name)();
  TextColumn get category => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {product, category}
  ];
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, "food_data.sqlite"));
    return NativeDatabase(file);
  });
}
@DriftDatabase(tables: [Foods, Products, ProductCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  Future<int> addFood(FoodsCompanion food) async {
    return await into(foods).insert(food);
  }
  Future<int> addProduct(Product product) async {
    return await into(products).insert(product);
  }

  // Stream<List<FoodEntry>> foodsInCategory(String? category) {
  //   if (category == null) {
  //     return (select(foods)..where((f) => f.category.isNull())).watch();
  //   } else {
  //     return (select(foods)..where((f) => f.category.equals(category)))
  //         .watch();
  //   }
  // }
  // Get all Food
  Stream<List<FoodEntry>> getAllFood() {
    return (select(foods)..where((tbl) => tbl.id.isNotNull())..orderBy([(tbl) => OrderingTerm.asc(tbl.expiryDate)])).watch();
  }

  // Get all Products
  Stream<List<Product>> getAllProducts() {
    return (select(products)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).watch();
  }

  // Delete a food by id
  Future<int> deleteFoodRecord(int id) async {
    return await (delete(foods)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Check if this product can be deleted
  Future<bool> isNotProductInDatabase(String name) async {
    var res = await (select(foods)..where((tbl) => tbl.name.equals(name))).get();
    return res.isEmpty;
  }

  // Delete a product by name
  Future<int> deleteProductRecord(String name) async {
    assert (await isNotProductInDatabase(name));
    return await (delete(products)..where((tbl) => tbl.name.equals(name))).go();
  }

  // Get all product names
  Future<List<String>> getAllProductNames() {
    final name = products.name;
    final query = (selectOnly(products))..addColumns([name]);
    return query.map((row) => row.read(name)!).get();
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