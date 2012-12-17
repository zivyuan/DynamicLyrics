//
//  LyricsCleaner.m
//  LyricX
//
//  Created by ziv yuan on 12-12-12.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "LyricsCleaner.h"
#import "RegexKitLite.h"

@implementation LyricsCleaner

+ (LyricsCleaner *)instance
{
    static dispatch_once_t once;
    static LyricsCleaner *__instance;
    dispatch_once(&once, ^ { __instance = [[LyricsCleaner alloc] init]; });
    return __instance;
}


-(void)loadKeywords:(NSString *)keywordsFilePath
{
	
}

-(NSString *)cleanLyrics:(NSString *)lyrics
{
	NSRange rng = [lyrics rangeOfRegex:@"(---|[qQ]{2,}|music|MUSIC|Music|-=|={2,})"];
	if (rng.length > 0) {
		return @"";
	}

	return lyrics;
}

@end
