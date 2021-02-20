import 'dart:io';
import 'dart:convert';
import 'clients_table.dart';
import 'restaurants_table.dart';

class Server {
  final _server = HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8888,
  );

  static HttpRequest _request;
  static var _data;
  final delegator = <String, Map<String, Function>>{
    'POST': {
      '/restaurant/register': _restaurantRegister,
      '/restaurant/login': _restaurantLogin,
      '/restaurant/check/login': _restaurantCheckLogin,
      '/client/register': _clientRegister,
      '/client/login': _clientLogin,
    },
  };

  static final Function _restaurantRegister = () async {
    _data = await _getData(_request);
    _request.response.statusCode = await Restaurant().create(_data);
    await _request.response.close();
  };

  static final Function _restaurantLogin = () async {
    _data = await _getData(_request);
    Map<String, dynamic> user = await Restaurant().login(_data);
    if (user != null) {
      _request.response.statusCode = HttpStatus.ok;
      _request.response.write(jsonEncode(user));
      await _request.response.close();
      return;
    }
    _request.response.statusCode = HttpStatus.unauthorized;
    _request.response.write(user);
    await _request.response.close();
  };

  static final Function _restaurantCheckLogin = () async {
    print(_request);
    _data = await _getData(_request);
    print(_data);
    // Map<String, dynamic> user = await Restaurant().login(_data);
    // if (user != null) {
    //   _request.response.statusCode = HttpStatus.ok;
    //   _request.response.write(jsonEncode(user));
    //   await _request.response.close();
    //   return;
    // }
    // _request.response.statusCode = HttpStatus.unauthorized;
    // _request.response.write(user);
    // await _request.response.close();
  };

  static final Function _clientRegister = () async {
    _data = await _getData(_request);
    _request.response.statusCode = await Client().create(_data);
    await _request.response.close();
  };

  static final Function _clientLogin = () async {
    _data = await _getData(_request);
    Map<String, dynamic> user = await Client().login(_data);
    if (user != null) {
      _request.response.statusCode = HttpStatus.ok;
      _request.response.write(jsonEncode(user));
      await _request.response.close();
      return;
    }
    _request.response.statusCode = HttpStatus.unauthorized;
    _request.response.write(user);
    await _request.response.close();
  };

  static void handleOptions() async {
    _addCorsHeaders();
    _request.response.statusCode = HttpStatus.noContent;
    await _request.response.close();
  }

  static Future _getData(HttpRequest res) async {
    _addCorsHeaders();
    try {
      var content = await utf8.decoder.bind(res).join();
      var data = jsonDecode(content) as Map;
      return data;
    } catch (e) {
      res.response.statusCode = HttpStatus.badRequest;
      res.response.write('Failed decoding content: ${e}');
      await res.response.close();
      return Null;
    }
  }

  static void _addCorsHeaders() {
    _request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'POST, OPTIONS')
      ..add('Access-Control-Allow-Headers',
          'Origin, X-Requested-With, Content-Type, Accept');
  }

  Stream<HttpRequest> requestListener() async* {
    await for (HttpRequest request in await _server) {
      _request = request;
      yield request;
    }
  }
}

Future main() async {
  final server = Server();
  server.requestListener().listen((request) async {
    request.method == 'OPTIONS'
        ? Server.handleOptions()
        : server.delegator[request.method][request.uri.path]();
  }, cancelOnError: false);
}
