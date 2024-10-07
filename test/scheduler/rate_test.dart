import 'package:bili_novel_packer/scheduler/scheduler.dart';
import 'package:bili_novel_packer/util/http_util.dart';
import 'package:test/test.dart';

void main() {
  test(
    "BiliNovel Rate",
    () async {
      // 极限大约为49/min
      Scheduler scheduler = Scheduler(49, Duration(minutes: 1));
      // 先等待半分钟 等RateLimit解除
      await Future.delayed(Duration(seconds: 40));
      for (int i = 1; i <= 100; i++) {
        scheduler.run((_) async {
          String html = await HttpUtil.getString(
            "https://www.bilinovel.com/novel/1860/67643.html",
          );
          if (html.contains("nginx") ||
              html.contains("rate limited") ||
              html.contains("Error") ||
              html.contains("error code")) {
            throw "ERROR";
          } else {
            print("$i OK");
          }
        });
      }
      await scheduler.wait();
    },
    timeout: Timeout(Duration(hours: 1)),
  );

  test(
    "Wenku Rate",
    () async {
      // 无限制
      Scheduler scheduler = Scheduler(0, Duration(minutes: 1));
      // 先等待半分钟 等RateLimit解除
      // await Future.delayed(Duration(seconds: 40));
      for (int i = 1; i <= 100; i++) {
        scheduler.run((_) async {
          String html = await HttpUtil.getStringFromGbk(
            "http://www.wenku8.net/novel/3/3762/157101.htm",
          );
          if (html.contains("nginx") ||
              html.contains("rate limited") ||
              html.contains("Error") ||
              html.contains("error code")) {
            throw "ERROR";
          } else {
            print("$i OK");
          }
        });
      }
      await scheduler.wait();
    },
    timeout: Timeout(Duration(hours: 1)),
  );
}