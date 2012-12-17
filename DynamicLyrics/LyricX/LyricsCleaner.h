//
//  LyricsCleaner.h
//  LyricX
//
//  Created by ziv yuan on 12-12-12.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricsCleaner : NSObject

+ (LyricsCleaner *)instance;

- (void)loadKeywords:(NSString *)keywordsFilePath;

- (NSString *)cleanLyrics:(NSString *)lyrics;

@end
