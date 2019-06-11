import 'dart:io';

import 'package:cinch/cinch.dart';

import 'test_service.dart' as test;

main(List<String> args) async {
  test.TestService service = test.TestService();
  test.Response response = await service.upload(UploadFileInfo(
      File('/Users/liaojianxun/Downloads/Resume.docx'), 'test.docx'));
  print(response);
  response = await service.multiUpload(88, {
    "file0": UploadFileInfo(
        File('/Users/liaojianxun/Downloads/Resume.docx'), 'test0.docx'),
    "file1": UploadFileInfo(
        File('/Users/liaojianxun/Downloads/Resume.docx'), 'test1.docx')
  });
  print(response);
  response = await service.multiUpload(99, {
    for (var i = 0; i < 5; i++)
      "file$i": UploadFileInfo(
          File('/Users/liaojianxun/Downloads/Resume.docx'), 'test$i.docx'),
  });
  print(response);
}
