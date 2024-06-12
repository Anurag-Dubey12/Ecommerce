import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'CartItem.dart';
import 'OrderData.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'order_history.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE orders(id INTEGER PRIMARY KEY,itemName TEXT, itemPrice REAL, quantity INTEGER, orderDate TEXT)',
        );
      },
    );
  }

  Future<void> insertOrder(OrderData order) async {
    final db = await database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OrderData>> orders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');

    return List.generate(maps.length, (i) {
      return OrderData(
        id: maps[i]['id'],
        itemName: maps[i]['itemName'],
        itemPrice: maps[i]['itemPrice'],
        quantity: maps[i]['quantity'],
        orderDate: DateTime.parse(maps[i]['orderDate']),
      );
    });
  }

  Future<void> insertCartItems(List<CartItem> cartItems, double total) async {
    final db = await database;
    Batch batch = db.batch();
    for (var item in cartItems) {
      batch.insert(
        'orders',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');

    return List.generate(maps.length, (i) {
      return CartItem(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['price'],
        maps[i]['imagePath'],
        maps[i]['quantity'],
      );
    });
  }

  Future<void> updateCartItem(CartItem item) async {
    final db = await database;
    await db.update(
      'cart',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.productId],
    );
  }

  Future<void> deleteCartItem(int id) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

}
