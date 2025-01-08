import 'dart:io';

import 'package:bili_novel_packer/light_novel/base/light_novel_model.dart';
import 'package:bili_novel_packer/log.dart';
import 'package:bili_novel_packer/novel_packer.dart';
import 'package:bili_novel_packer/pack_argument.dart';
import 'package:console/console.dart';

const String gitUrl = "https://github.com/Montaro2017/bili_novel_packer";
const String version = "0.2.29";

void main(List<String> args) async {
  printWelcome();
  while (true) {
    try {
      await start();
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      print(e);
      print(stackTrace);
      print("运行出错，按回车键退出.($version)");
      Console.readLine();
      break; // 发生错误时退出循环
    }
  }
}

void printWelcome() {
  print("欢迎使用轻小说打包器!");
  print("作者: Spark");
  print("当前版本: $version");
  print("如遇报错请先查看能否正常访问输入网址");
  print("否则请至开源地址携带报错信息进行反馈: $gitUrl");
}

Future<void> start() async {
  var url = readUrl();
  String id = url.split('/')[4].split('.')[0];
  logger.i("version: $version");
  logger.i("URL: $url");
  var packer = NovelPacker.fromUrl(url);
  print("正在加载数据...");
  await packer.init();
  logger.i(packer.novel);
  printNovelDetail(packer.novel);
  var arg = readPackArgument(packer.catalog);

  // 默认设置
  arg.combineVolume = false; // 不合并分卷
  arg.addChapterTitle = true; // 添加章节标题

  String folderName = "$id${packer.novel.title}";

  Directory(folderName).createSync();

  await packer.pack(arg);

  print("全部任务已完成，按回车键继续下载下一个小说，或输入 'exit' 退出.");
  String? input = Console.readLine();
  if (input == 'exit') {
    exit(0);
  }
}

String readUrl() {
  String? url;
  do {
    print("请输入URL(支持哔哩轻小说&轻小说文库):");
    url = stdin.readLineSync();
  } while (url == null || url.isEmpty);
  return url;
}

void printNovelDetail(Novel novel) {
  Console.write("\n");
  Console.write(novel.toString());
}

PackArgument readPackArgument(Catalog catalog) {
  var arg = PackArgument();
  var select = readSelectVolume(catalog);
  arg.packVolumes = select;

  // 默认设置
  arg.combineVolume = false; // 不合并分卷
  arg.addChapterTitle = true; // 添加章节标题

  // 如果没有选择任何分卷，默认选择全部
  if (arg.packVolumes.isEmpty) {
    arg.packVolumes = catalog.volumes; // 选择全部分卷
  }

  return arg;
}

List<Volume> readSelectVolume(Catalog catalog) {
  Console.write("\n");
  for (int i = 0; i < catalog.volumes.length; i++) {
    Console.write("[${i + 1}] ${catalog.volumes[i].volumeName}\n");
  }
  Console.write("---------------\n");
  Console.write("[0] 选择全部\n");

  // 默认选择全部分卷
  String input = "0"; // 直接设置为0
  Console.write("请选择需要下载的分卷(可输入如1-9进行范围选择以及如2,5单独选择):\n");

  List<Volume> selectVolumeIndex = [];

  if (input == "0") {
    // 默认选择全部分卷
    for (int i = 0; i < catalog.volumes.length; i++) {
      selectVolumeIndex.add(catalog.volumes[i]);
    }
    return selectVolumeIndex;
  }

  input = input.trim();
  input = input.replaceAll("，", ",");
  input = input.replaceAll(" ", ",");
  List<String> parts = input.split(",");

  for (var part in parts) {
    List<String> range = part.split("-");
    if (range.length == 1) {
      int index = int.parse(range[0]) - 1;
      selectVolumeIndex.add(catalog.volumes[index]);
    } else {
      int from = int.parse(range[0]);
      int to = int.parse(range[1]);
      if (from > to) {
        int tmp = from;
        from = to;
        to = tmp;
      }
      for (int i = from; i <= to; i++) {
        int index = i - 1;
        selectVolumeIndex.add(catalog.volumes[index]);
      }
    }
  }

  // 如果没有选择任何分卷，默认选择全部
  if (selectVolumeIndex.isEmpty) {
    selectVolumeIndex = catalog.volumes; // 选择全部分卷
  }

  return selectVolumeIndex;
}
