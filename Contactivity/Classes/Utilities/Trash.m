//
//  Trash.m
//  Contactivity
//
//  Created by Erik Solis on 7/11/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "Trash.h"

@implementation Trash

+ (void)cleanAllTMP {
    NSString *tempPath = NSTemporaryDirectory();
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (int i = 0; i < [dirContents count]; i++) {
        NSString *file = [NSString stringWithFormat:@"%@%@", tempPath, [dirContents objectAtIndex:i]];
        [fileManager removeItemAtPath:file error:nil];
    }
}

+ (void)cleanRestKitLibraryCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [paths objectAtIndex:0];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachesPath error:nil];
    NSArray *onlyRKClientRequestCache = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'RKClientRequestCache'"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (int i = 0; i < [onlyRKClientRequestCache count]; i++) {
        NSString *file = [NSString stringWithFormat:@"%@/%@", cachesPath, [onlyRKClientRequestCache objectAtIndex:i]];
        [fileManager removeItemAtPath:file error:nil];
    }
}

@end
