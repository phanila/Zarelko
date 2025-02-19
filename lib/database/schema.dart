import 'package:powersync/powersync.dart';

// Table names
const productsTable = 'products';
const productCategoriesTable = 'product_categories';
const foodsTable = 'foods';

Schema schema = Schema([
  // Products table
  const Table(productsTable, [
    // Column.text('id'),
    Column.text('name'),
    Column.integer('open_life'),
    Column.text('storing_location'),
    Column.text('open_location'),
    Column.text('unit'),
    Column.integer('basic_amount'),
  ],),

  // Product Categories table
  const Table(productCategoriesTable, [
    // Column.text('id'),
    Column.text('product'),
    Column.text('category'),
  ]),

  // Foods table
  const Table(foodsTable, [
    // Column.text('id'),
    Column.text('name'),
    Column.text('desc'),
    Column.text('expiry_date'),
    Column.text('opening_date'),
    Column.integer('amount'),
  ]),
]);
