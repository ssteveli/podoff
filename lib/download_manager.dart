import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast/db.dart';

class DownloadManager with ChangeNotifier {
  final Dio dio = new Dio();
  final Db _db = Db();

  Stream<double> download(String id, String url) async* {
    Directory directory = await getTemporaryDirectory();
    File f = File('${directory.path}/$id');

    if (await f.exists()) {
      print('${f.path} downloading skipped, file already exists');
    } else {
      final StreamController<double> _progress = StreamController<double>();

      print('starting download from: $url');
      dio.download(url, f.path, onReceiveProgress: (c, t) {
        print('download progress of $id: ${c / t}');
        _progress.add(c / t);
      }).then((response) async {
        print('download completed, status code: ${response.statusCode}');
        print('exists: ${await f.exists()}');
        print('size: ${await f.length()}');

        _progress.close();
      });

      yield* _progress.stream;
    }
  }

  Future<bool> exists(String id) async {
    Directory directory = await getTemporaryDirectory();
    File f = File('${directory.path}/$id');

    return await _db.exists(id) && await f.exists();
  }

  Future<File> getDownloadedFile(String id) async {
    Directory directory = await getTemporaryDirectory();
    File f = File('${directory.path}/$id');

    if (await f.exists()) return f;

    return null;
  }
}
