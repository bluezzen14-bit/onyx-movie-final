import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static Future<void> downloadToGallery(String url, String fileName) async {
    await Permission.storage.request();
    final dir = await getExternalStorageDirectory();
    final savePath = "${dir!.path}/$fileName";
    final onyxDir = Directory("/storage/emulated/0/Movies/Onyx Movies/Movies & Series");
    if (!await onyxDir.exists()) await onyxDir.create(recursive: true);
    
    await Dio().download(url, savePath);
    await GallerySaver.saveVideo(savePath, albumName: "Onyx Movies");
    // Also copy to Onyx folder
    await File(savePath).copy("${onyxDir.path}/$fileName");
  }
}
