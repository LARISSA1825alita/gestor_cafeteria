import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client? _client;
  final Uri? baseUrl;
  final Duration timeout;
  //Clase Client
  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       baseUrl = Uri.parse(
         baseUrl ??
             (const String.fromEnvironment('API_URL').isNotEmpty
                 ? const String.fromEnvironment('API_URL')
                 : (kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000')),
       );
  //POST,GET,PATCH,DELETE
  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, Object body) => _send('POST', path, body);
  Future<dynamic> patch(String path, Object body) => _send('PATCH', path, body);
  Future<dynamic> update(String path, Object body) =>
      _send('UPDATE', path, body);
  Future<void> delete(String path) => _send('DELETE', path);

  //Funcion SEND -> Mandar la peticion al Servicio, esperar una respuesta y adecuarlo para flutter

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    //Request: Va arma la peticion con la inyeccion de los HEADERS
    final request = http.Request(method, baseUrl!.resolve(path))
      ..headers['Accept'] = 'application/json';
    //Si es una peticion que tiene que mandar un body
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    //Guardar la respuesta del servicio
    final http.Response response;
    //El response se va a tratar segun el caso con el servicio respondio
    try {
      response = await _client!
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }
    final json = _tryDecode(response);
    final code = response.statusCode;
    if (code >= 200 && code <= 300) return json;
    //Si no fue exitosa, se convierte en el Failure que corresponde
    throw _mapFailure(code, json);
  }

  //Convierte el codigo de estado en el Failure correspondiente
  Failure _mapFailure(int code, dynamic json) {
    //detail puede ser texto (404, 409, simulados), lista (422) o null (no JSON)
    final detail = json is Map ? json['detail'] : null;

    return switch (code) {
      404 => NotFoundFailure(_mensaje(detail, code)),
      409 => ConflictFailure(_mensaje(detail, code)),
      422 => ValidationFailure(_campos(detail)),
      >= 500 && < 600 => ServerFailure(code),
      _ => UnexpectedFailure(code, _mensaje(detail, code)),
    };
  }

  //Extrae el mensaje cuando detail es texto; si no, usa un texto generico
  String _mensaje(dynamic detail, int code) {
    if (detail is String && detail.isNotEmpty) return detail;
    return 'Error inesperado ($code)';
  }

  //Extrae los campos de un 422: clave = loc[1], valor = msg
  //Ejemplo: {"detail": [{"loc": ["body", "customer"], "msg": "..."}]}
  Map<String, String> _campos(dynamic detail) {
    final fields = <String, String>{};
    if (detail is! List) return fields;
    for (final error in detail) {
      if (error is! Map) continue;
      final loc = error['loc'];
      final campo = loc is List && loc.length > 1 ? '${loc[1]}' : 'general';
      fields[campo] = '${error['msg'] ?? ''}';
    }
    return fields;
  }

  dynamic _tryDecode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }
}
