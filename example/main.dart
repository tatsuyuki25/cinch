import 'dart:io';

import 'package:cinch/cinch.dart';

import 'test_service.dart' as test;

Future<void> main(List<String> args) async {
  final service = test.TestService();
  test.Response response = await service.upload(MultipartFile.fromFileSync(
      '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test.docx'));
  print(response);
  response = await service.multiUpload(88, <String, MultipartFile>{
    'file0': MultipartFile.fromFileSync(
        '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test0.docx'),
    'file1': MultipartFile.fromFileSync(
        '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test1.docx')
  });
  print(response);
  response = await service.multiUpload(99, <String, MultipartFile>{
    for (var i = 0; i < 5; i++)
      'file$i': MultipartFile.fromFileSync(
          '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test$i.docx'),
  });
  print(response);
}
