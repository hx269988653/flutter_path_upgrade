
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class FlutterPathUpgrade {
  final String original_so_name = 'original.so';
  FlutterPathUpgrade();
  static const MethodChannel _platform =
      const MethodChannel('flutter_path_upgrade');

  String rootDir;
  String oldfile;
  String newfile;
  String patchfile;

  Future<int> init(String outname) async{
    rootDir = await getDataDir('libs');

    oldfile = await getUpgradeFile;
    if(oldfile == null || oldfile.isEmpty || !File(oldfile).existsSync()){
      var sopath = await getlibappso(rootDir);
      if(sopath == null || sopath.isEmpty) {
        return 0;
      } else {
        oldfile = sopath;
      }
    }

    newfile = '$rootDir/$outname.so';
    patchfile = '$rootDir/p.so';

    print('=$rootDir=$oldfile==$newfile===$patchfile================');

    return 1;
  }

  Future<String> getlibappso(String savePath) async{
    // libapp.so -> app
    var libappsoPath = await findNativeLibraryPath('app');
    if(libappsoPath == null || libappsoPath.isEmpty) {
      return null;
    }

    if(libappsoPath.contains('.apk!')){
      // AAB方式
      try {
        var split = libappsoPath.split('!/');
        String soapk = split[0];
        String archSO = split[1];
        String saveFile = '$savePath/$original_so_name';

        if(await myUnZip(soapk, archSO, saveFile) == 1) {
          return saveFile;
        } else {
          return null;
        }
      }catch(e){
        print(e);
        return null;
      }
    } else {
      // APK方式
      return libappsoPath;
    }
  }

  // archiveFilePath 必须是这种: lib/arm64-v8a/libapp.so
  Future<int> myUnZip(String zipPath, String archiveFilePath, String savePath) async{
    print('===unzip====$zipPath====$archiveFilePath==$savePath===');
    if(zipPath==null || zipPath.isEmpty
        || archiveFilePath==null || archiveFilePath.isEmpty
        || savePath==null || savePath.isEmpty){

      print('====unzip->>参数错误===$zipPath====$archiveFilePath==$savePath===');
      return 0;
    }

    if(!File(zipPath).existsSync()){
      print('====unzip->>压缩包文件不存在====$zipPath====$archiveFilePath==$savePath===');
      return 0;
    }

    try {
      // 从磁盘读取Zip文件。
      List<int> bytes = File(zipPath).readAsBytesSync();
      // 解码Zip文件
      Archive archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile file = archive.findFile(archiveFilePath);
      if(file == null){
        print('====unzip->>需要解压的文件不存在====$zipPath====$archiveFilePath==$savePath===');
        return 0;
      } else {
        var saveFile = File(savePath);

        if(saveFile.existsSync()){
          saveFile.deleteSync();
        }

        saveFile
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);

        print('====unzip->>解压成功====$zipPath====$archiveFilePath==$savePath===');
        return 1;
      }
    }catch(e){
      print('====unzip->>解压失败====$zipPath====$archiveFilePath==$savePath===');
      print(e);

      return 0;
    }

    // // 将Zip存档的内容解压缩到磁盘。
    // for (ArchiveFile file in archive) {
    //   print('=======${file.name}======');
    //   if (file.isFile) {
    //     List<int> data = file.content;
    //     File(_zipRootPath+"/"+file.name)
    //       ..createSync(recursive: true)
    //       ..writeAsBytesSync(data);
    //   } else {
    //     Directory(_zipRootPath+"/"+file.name)
    //       ..create(recursive: true);
    //   }
    // }
  }

  ///下载.so
  Future<int> downloadSO(String url) async{
    print(url);
    print('=========xxxxxxxxx=============');
    print(rootDir);
    int state = 1;
    await Dio().download(url, patchfile,onReceiveProgress: (count, total){
      print(count);
      print(total);//总大小
      print('=========downloadSO=============');
    }).catchError((dd){
      print('========下载错误===$dd==========');
      state = 0;
    });
    return state;
  }

  ///验证合成的.so是否正确
  Future<String> calculateMD5SumAsync(String filePath) async {
    print('=========calculateMD5SumAsync=============');
    String ret = "";

    var file = new File(filePath);
    if (await file.exists()) {
      try {
        var hash = await md5.bind(file.openRead()).first;
        ret = hex.encode(hash.bytes).toUpperCase();
      } catch (exception) {
        print("Unable to evaluate the MD5 sum :$exception");
      }
    } else {
      print("'" + filePath + "' doesn't exits so unable to evaluate its MD5 sum.");
    }

    print('=========calculateMD5SumAsync========$ret=====');
    return ret;
  }

  ///重启
  Future<void> reStart() async{
    print('========reStart==============');
    _platform.invokeMethod("restart", '');
  }

  /// 合并.so
  Future<int> merge(String oldfile, String newfile, String patch) async{
    print('========merge==============');
    return await _platform.invokeMethod ( "merge" , {'oldfile':oldfile, 'newfile':newfile, 'patch':patch});
  }
  /// 获取DataDir
  Future<String> getDataDir(String name) async{
    print('========getDataDir==============');
    return await _platform.invokeMethod ('getDataDir', name);
  }

  /// 获取libapp.so文件路径
  Future<String> findNativeLibraryPath(String name) async{
    print('========findNativeLibraryPath==============');
    return await _platform.invokeMethod ('findNativeLibraryPath', name);
  }

  /// 保存更新文件名字
  Future<void> setUpgradeFile(String name) async{
    print('=====flutter===setUpgradeFile=======$name=======');
    return await _platform.invokeMethod ('setUpgradeFile', name);
  }

  /// 获取更新文件名字
  Future<String> get getUpgradeFile async{
    print('=====flutter===getUpgradeFile==============');
    return await _platform.invokeMethod ('getUpgradeFile', '');
  }
}
