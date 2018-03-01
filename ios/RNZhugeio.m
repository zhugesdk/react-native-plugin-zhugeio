#import "RNZhugeio.h"
#import <Zhugeio/Zhuge.h>

@implementation RNZhugeio

RCT_EXPORT_MODULE(Zhugeio)

RCT_EXPORT_METHOD(openDebug){
    NSLog(@"openDebug");
    [[Zhuge sharedInstance].config setDebug:true];
}

RCT_EXPORT_METHOD(openLog){
    //ignore, ios not provide
}

RCT_EXPORT_METHOD(init:(NSString *)appKey channel:(NSString *)channel){
  //ignore,ios SDK can't init in here.
}

RCT_EXPORT_METHOD(setUploadURL:(NSString *)url backupURL:(NSString *)backup){
    NSLog(@"setUploadURL with %@ and %@",url,backup);
    [[Zhuge sharedInstance]setUploadURL:url andBackupUrl:backup];
}

RCT_EXPORT_METHOD(identify:(NSString *)uid properties:(NSDictionary *)pro){
    NSLog(@"identify with %@",uid);
    [[Zhuge sharedInstance]identify:uid properties:pro];
}

RCT_EXPORT_METHOD(track:(NSString *)name properties:(NSDictionary *)pro)
{
    Zhuge *zhuge = [Zhuge sharedInstance];
    NSLog(@"track with %@",name);
    [zhuge track:name properties:pro];
}

RCT_EXPORT_METHOD(startTrack:(NSString *)name){
    NSLog(@"startTrack with %@",name);
    [[Zhuge sharedInstance]startTrack:name];
}

RCT_EXPORT_METHOD(endTrack:(NSString *)name properties:(NSDictionary *)pro){
    NSLog(@"endTrack with %@",name);
    [[Zhuge sharedInstance] endTrack:name properties:pro];
}

@end
