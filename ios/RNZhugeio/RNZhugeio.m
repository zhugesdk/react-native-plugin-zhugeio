#import "RNZhugeio.h"
#import <Zhugeio/Zhuge.h>

@implementation RNZhugeio

RCT_EXPORT_MODULE(Zhugeio)

RCT_EXPORT_METHOD(openDebug){
  [[Zhuge sharedInstance].config setDebug:true];
}

RCT_EXPORT_METHOD(openLog){
  //ignore, ios not provide
}

RCT_EXPORT_METHOD(setUploadURL:(NSString *)url backupURL:(NSString *)backup){
  [[Zhuge sharedInstance]setUploadURL:url andBackupUrl:backup];
}

RCT_EXPORT_METHOD(identify:(NSString *)uid properties:(NSDictionary *)pro){
  [[Zhuge sharedInstance]identify:uid properties:pro];
}

RCT_EXPORT_METHOD(track:(NSString *)name properties:(NSDictionary *)pro)
{
  Zhuge *zhuge = [Zhuge sharedInstance];
  // Your implementation here
  NSLog(@"track with %@",name);
  [zhuge track:name properties:pro];
}

RCT_EXPORT_METHOD(startTrack:(NSString *)name){
  [[Zhuge sharedInstance]startTrack:name];
}

RCT_EXPORT_METHOD(endTrack:(NSString *)name properties:(NSDictionary *)pro){
  [[Zhuge sharedInstance] endTrack:name properties:pro];
}

@end
