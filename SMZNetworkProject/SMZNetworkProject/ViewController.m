//
//  ViewController.m
//  SMZNetworkProject
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import "ViewController.h"
#import "SMZURLSessionManager.h"

@interface ViewController ()

@end

static NSString *videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SMZURLSessionManager sharedInstance] initFileManager];
    [[SMZURLSessionManager sharedInstance] initFunction];
    
    [[SMZURLSessionManager sharedInstance] initSessionWithURL:videoUrl timeOut:10];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)dealloc{
    [[SMZURLSessionManager sharedInstance] destoryAll];
}


@end
