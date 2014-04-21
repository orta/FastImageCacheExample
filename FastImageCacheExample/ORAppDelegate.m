//
//  ORAppDelegate.m
//  FastImageCacheExample
//
//  Created by Orta on 4/21/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORAppDelegate.h"
#import <FastImageCache/FICImageCache.h>
#import "ORImage.h"

@interface ORAppDelegate(FICImageCacheDelegate) <FICImageCacheDelegate>

@end

@implementation ORAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Configure the image cache
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setDelegate:self];

    // Reuse the Path image formats
    FICImageFormatDevices squareImageFormatDevices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    FICImageFormat *squareImageFormat16BitBGR = [FICImageFormat formatWithName:FICDPhotoSquareImage16BitBGRFormatName family:FICDPhotoImageFormatFamily
                                                                     imageSize:FICDPhotoSquareImageSize style:FICImageFormatStyle16BitBGR
                                                                  maximumCount:250 devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
    
    [sharedImageCache setFormats:@[squareImageFormat16BitBGR]];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

#pragma mark - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSURL *filePathURL = [entity sourceImageURLWithFormatName:formatName];        
        UIImage *sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePathURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity {
    return NO;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage {
    NSLog(@"%@", errorMessage);
}



@end
