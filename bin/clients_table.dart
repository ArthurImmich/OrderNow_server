import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'database.dart';

class Client {
  String email;
  String password;
  String token;

  Client({
    this.email,
    this.password,
  });

  void fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    return data;
  }

  Future<int> create(var data) async {
    try {
      fromJson(data);
      await Db().execute('INSERT INTO clients (email, password) VALUES (?, ?)',
          [email, password]);
      return HttpStatus.created;
    } catch (e) {
      print(e);
      return HttpStatus.conflict;
    }
  }

  Future<Map> login(var data) async {
    try {
      fromJson(data);
      Results user = await Db().getData(
          'SELECT id, email, token FROM clients WHERE email = ? AND password = ?',
          [data['email'], data['password']]);
      if (user.isNotEmpty) {
        var map = user.single.fields;
        if (!map.containsKey('token')) {
          map['token'] = JWT({
            'id': map['id'],
            'email': map['email']
          }).sign(SecretKey(
              's5v8y/B?E(H+MbQeThWmZq4t7w9z\$c&F)J@NcRfUjXn2r5u8x/A%D*G-KaPdSgVk'));
          await Db().execute('UPDATE clients SET token = ? WHERE id = ?',
              [map['token'], map['id']]);
        }
        return map;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static void createTable() async {
    var db = Db();
    var sql =
        'CREATE TABLE IF NOT EXISTS clients (id int NOT NULL AUTO_INCREMENT PRIMARY KEY, email varchar(255), password varchar(255), token varchar(255))';
    db.execute(sql);
  }
}
