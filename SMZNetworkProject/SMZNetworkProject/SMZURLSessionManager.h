//
//  SMZURLSessionManager.h
//  SMZNetworkProject
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMZURLSessionManager : NSObject

+ (SMZURLSessionManager *_Nullable) sharedInstance;

- (void) initFileManager;

- (void) initFunction;

- (void) initSessionWithURL:(NSString *_Nullable)stringURL timeOut:(NSInteger)timeOut;

- (NSString *)getDownloadedVideo;

- (BOOL) isEXistsFile;

- (void) destoryAll;

@end

NS_ASSUME_NONNULL_END
