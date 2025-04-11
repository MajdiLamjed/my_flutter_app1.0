import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  for (int i = 1; i < 4;i++){
    print('doone i : ');
    String? i = stdin.readLineSync();
    int inn = int.parse(i!);
    print(await getdata(inn));
  }
}

Future<String> getdata(int n) async {
  var data = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/$n'));
  String tit = jsonDecode(data.body)["title"];
  return tit;
}
