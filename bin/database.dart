import 'package:mysql1/mysql1.dart';

class Db {
  var dbConnection;
  final String _server = 'localhost';
  final int _port = 3306;
  final String _user = 'root';
  final String _db = 'ordernowdb';

  void connect() async {
    try {
      dbConnection = await MySqlConnection.connect(
        ConnectionSettings(
          host: _server,
          port: _port,
          user: _user,
          db: _db,
        ),
      );
    } catch (e) {
      print('Erro: $e');
    }
  }

  void disconnect() async {
    await dbConnection.close();
  }

  void execute(String sql, [List values]) async {
    try {
      await connect();
      await dbConnection.query(sql, values);
      disconnect();
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getData(String sql, [List values]) async {
    try {
      await connect();
      var data = await dbConnection.query(sql, values);
      disconnect();
      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
