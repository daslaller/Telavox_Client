import 'dart:convert';
import 'dart:developer';
import 'dart:io';

enum TelavoxApiType {
  extensions('extensions/', get: true, post: false),
  callHistory('calls/', get: true, post: false),
  dial('dial/', get: true, post: false),
  sms('sms/', get: true, post: false),
  hangup('hangup/', get: false, post: true),
  recordings('recordings/');

  static String baseUrl = 'https://api.telavox.se/';

  final String pointer;

  final bool get;

  final bool post;
  const TelavoxApiType(this.pointer, {this.get = false, this.post = false});
  String get endpoint => '$baseUrl$pointer';
  subsection(String appendedSection) => switch (this) {
    TelavoxApiType.extensions => '$endpoint$appendedSection',
    TelavoxApiType.callHistory => throw Exception(
      'Cannot append to call history endpoint',
    ),
    TelavoxApiType.dial => '$endpoint$appendedSection',
    TelavoxApiType.sms => '$endpoint$appendedSection',
    TelavoxApiType.hangup => throw Exception(
      'Cannot append to hangup endpoint',
    ),
    TelavoxApiType.recordings => '$endpoint$appendedSection',
  };
}

class TelavoxClient {
  final HttpClientCredentials credentials;
  final HttpClient client = HttpClient();
  TelavoxClient({required this.credentials});

  factory TelavoxClient.fromUserPassword(String user, String password) {
    return TelavoxClient(
      credentials: HttpClientBasicCredentials(user, password),
    );
  }
  factory TelavoxClient.fromJwtToken(String jwtToken) {
    return TelavoxClient(credentials: HttpClientBearerCredentials(jwtToken));
  }
  post(TelavoxApiType requestType) async {
    client.addCredentials(
      Uri.parse(TelavoxApiType.baseUrl),
      requestType.pointer,
      credentials,
    );
    if (requestType.post == false) {
      throw Exception('Cannot post to this endpoint');
    }
    HttpClientRequest request = await client.postUrl(
      Uri.parse(requestType.endpoint),
    );
    log('request: $request');
    var response = await request.close();
    log('response: $response');
    dynamic payload = await processResponse(response);
    log('payload: $payload');
  }

  get(TelavoxApiType requestType) async {
    client.addCredentials(
      Uri.parse(TelavoxApiType.baseUrl),
      requestType.pointer,
      credentials,
    );
    if (requestType.get == false) {
      throw Exception('Cannot get from this endpoint');
    }
    HttpClientRequest request = await client.getUrl(
      Uri.parse(requestType.endpoint),
    );
    log('request: $request');
    var response = await request.close();
    log('response: $response');
    dynamic payload = await processResponse(response);
    log('payload: $payload');
  }

  Future<List> processResponse(HttpClientResponse response) async {
    List<dynamic> payload = switch (response.statusCode) {
      200 => await jsonDecode(await response.transform(utf8.decoder).join()),
      401 => throw Exception('Unauthorized'),
      403 => throw Exception('Forbidden'),
      404 => throw Exception('Not Found'),
      500 => throw Exception('Internal Server Error'),
      _ => throw Exception('Unknown Error'),
    };
    return payload;
  }
}
