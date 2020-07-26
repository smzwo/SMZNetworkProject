//
//  SMZURLSessionManager.m
//  SMZNetworkProject
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import "SMZURLSessionManager.h"

@interface SMZURLSessionManager ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

// 下载相关
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *downLoadSession;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic, strong) NSURLRequest *videoRequest;
@property (nonatomic, strong) NSString *videoFileName;

@property (nonatomic, assign) double currentProgress;

// 下载内容相关
@property (nonatomic, strong) NSMutableDictionary *videoFilesDownloadedDic;
@property (nonatomic, strong) NSMutableArray *videoFileNameArr;


// 文件存储位置相关
@property (nonatomic, strong) NSFileManager *manager;
@property (nonatomic, strong) NSString *documentsPath;

@end

@implementation SMZURLSessionManager

+ (SMZURLSessionManager *_Nullable) sharedInstance{
    static SMZURLSessionManager *__singleton__;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __singleton__ = [[super allocWithZone:NULL] init];
    });
    return __singleton__;
}

- (void) initFileManager{
    // 获取document文件夹路径
    self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.manager = [NSFileManager defaultManager];
    self.videoFilesDownloadedDic = [[NSMutableDictionary alloc] init];
    self.videoFileNameArr = [[NSMutableArray alloc] init];
}

- (void) initFunction{
    self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.downLoadSession = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:[NSOperationQueue new]];
}

- (void) initSessionWithURL:(NSString *)stringURL timeOut:(NSInteger)timeOut{
    
    self.videoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:timeOut];
        
    self.downloadTask = [self.downLoadSession downloadTaskWithRequest:self.videoRequest];
    
    NSArray *stringURLArray = [stringURL componentsSeparatedByString:@"/"];
    self.videoFileName = [NSString stringWithFormat:@"/%@", stringURLArray.lastObject];
    
    NSLog(@"文件名%@,是否存在%d",self.videoFileName,[self.videoFileNameArr containsObject:self.videoFileName]);
    
    if (![self.videoFileNameArr containsObject:self.videoFileName]){
        [self.videoFileNameArr addObject:self.videoFileName];
        NSLog(@"数组中的名字%lu", (unsigned long)self.videoFileNameArr.count);
        [self.downloadTask resume];
    } else {
        NSLog(@"文件已存在");
    }
    
}
#pragma mark - 向外返回数据用
- (NSString *)getDownloadedVideo{
    return [self.videoFilesDownloadedDic valueForKey:self.videoFileName];
}

- (BOOL) isExistsFile{
    NSString *file = [self.videoFilesDownloadedDic valueForKey:self.videoFileName];
    if ([self.manager fileExistsAtPath:file]){
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 下载代理实现
// 下载过程
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    self.currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
//    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"进度%f", self.currentProgress);
//    });
}

// 下载完成，无论成败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"function == %s, line == %d, error == %@", __FUNCTION__, __LINE__, error);
}

// 下载完成，获取下载内容
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *file = [self.documentsPath stringByAppendingString:self.videoFileName];
    
    [self.videoFilesDownloadedDic setValue:file forKey:self.videoFileName];
    NSLog(@"file%@", file);
    

    NSError *err = nil;
    
    // 删除之前相同的文件
    BOOL remove  = [self.manager removeItemAtPath:file error:nil];
    
    // 移动用move，复制用copy
    BOOL success = [self.manager moveItemAtPath:location.path toPath:file error:&err];
    
    if (success){
        NSLog(@"移动成功");
    } else {
        NSLog(@"失败%@", err);
    }
}

#pragma mark - 卸载能力
- (void)destoryAll{
    for (int i = 0; i < self.videoFileNameArr.count; i++){
        [self.manager removeItemAtPath:[self.videoFilesDownloadedDic valueForKey:self.videoFileNameArr[i]] error:nil];
        
    }
    [self.videoFilesDownloadedDic removeAllObjects];
    [self.videoFileNameArr removeAllObjects];
    self.downloadTask = nil;
    self.manager = nil;
}

@end
