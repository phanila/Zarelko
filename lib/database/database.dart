import 'package:drift/drift.dart';
import 'dart:io';
import 'package:powersync/powersync.dart' show PowerSyncDatabase, uuid;
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:drift_sqlite_async/drift_sqlite_async.dart';
part 'database.g.dart';

@DataClassName('FoodEntry')
class Foods extends Table {
  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().references(Products, #name)();
  TextColumn get desc => text().nullable()();
  DateTimeColumn get expiryDate => dateTime()();
  DateTimeColumn get openingDate => dateTime().nullable()();
  IntColumn get amount => integer().nullable()();
}
@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().unique()();
  IntColumn get openLife => integer()();
  TextColumn get storingLocation => text().nullable()();
  TextColumn get openLocation => text().nullable()();
  TextColumn get unit => text().nullable()();
  IntColumn get basicAmount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
@DataClassName('ProductCategory')
class ProductCategories extends Table {
  TextColumn get id => text().clientDefault(() => uuid.v4())();
  TextColumn get product => text().references(Products, #name)();
  TextColumn get category => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {product, category}
  ];
}

@DriftDatabase(tables: [Foods, Products, ProductCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase(PowerSyncDatabase db) : super(SqliteAsyncDriftConnection(db));

  @override
  int get schemaVersion => 3;

  Future<int> addFood(FoodsCompanion food) async {
    return await into(foods).insert(food);
  }
  Future<int> addOrUpdateProduct(ProductsCompanion product) async {
    if (await isNotProductInDatabase(product.name.value)) {
      return await into(products).insert(product);
    } else {
      return await (update(products)..where((tbl) => tbl.name.equals(product.name.value))).write(product,);
    }
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
  Future<int> deleteFoodRecord(String id) async {
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
  Future<int> updateFoodRecord({required String id, FoodEntry? food}) async {
    // final existingRecord = await (select(foods)..where((tbl) => tbl.id.equals(id))).getSingle();
    // final newFood = food ?? existingRecord.data;
    return await (update(foods)..where((tbl) => tbl.id.equals(id))).write(
      food!,
    );
  }
}