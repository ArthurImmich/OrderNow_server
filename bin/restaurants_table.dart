import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'database.dart';

class Restaurant {
  String email;
  String password;
  String cnpj;
  String adress;
  String number;
  String city;
  String url;
  String token;
  String name;
  String descricao;

  Restaurant(
      {this.email,
      this.password,
      this.cnpj,
      this.adress,
      this.number,
      this.city,
      this.name,
      this.descricao,
      this.url});

  void fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    cnpj = json['cnpj'];
    adress = json['adress'];
    number = json['number'];
    city = json['city'];
    name = json['name'];
    descricao = json['descricao'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['cnpj'] = cnpj;
    data['adress'] = adress;
    data['number'] = number;
    data['city'] = city;
    data['descricao'] = descricao;
    data['name'] = name;
    data['url'] = url;
    return data;
  }

  Future<int> create(var data) async {
    try {
      fromJson(data);
      await Db().execute(
          'INSERT INTO restaurants (email, password, cnpj, adress, number, city, url, name, descricao) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [email, password, cnpj, adress, number, city, url, name, descricao]);
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
          'SELECT id, email, token FROM restaurants WHERE email = ? AND password = ?',
          [data['email'], data['password']]);
      if (user.isNotEmpty) {
        var map = user.single.fields;
        if (!map.containsKey('token')) {
          map['token'] = JWT({
            'id': map['id'],
            'email': map['email']
          }).sign(SecretKey(
              's5v8y/B?E(H+MbQeThWmZq4t7w9z\$c&F)J@NcRfUjXn2r5u8x/A%D*G-KaPdSgVk'));
          await Db().execute('UPDATE restaurants SET token = ? WHERE id = ?',
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
        'CREATE TABLE IF NOT EXISTS restaurants (id int NOT NULL AUTO_INCREMENT PRIMARY KEY, email varchar(255), password varchar(255), token varchar(255),'
        'cnpj varchar(14), adress varchar(255), number varchar(5), city varchar(255), url varchar(255), name varchar(255), descricao varchar(255))';
    db.execute(sql);
  }
}
