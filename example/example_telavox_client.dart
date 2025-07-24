import 'dart:developer';

import 'package:telavox_client/telavox_client.dart';

TelavoxClient client = TelavoxClient.fromUserPassword(
  '0455344722',
  '55Nord0055',
);

void main() {
  log('launching...', name: 'main', level: 10);
  client.get(TelavoxApiType.extensions).then((value) => print(value));
}
