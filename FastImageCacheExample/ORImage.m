//
//  ORImage.m
//  FastImageCacheExample
//
//  Created by Orta on 4/21/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORImage.h"
#import <FastImageCache/FICUtilities.h>

NSString *const FICDPhotoImageFormatFamily = @"FICDPhotoImageFormatFamily";
NSString *const FICDPhotoSquareImage16BitBGRFormatName = @"com.path.FastImageCacheDemo.FICDPhotoSquareImage16BitBGRFormatName";
CGSize const FICDPhotoSquareImageSize = {240, 240};

@implementation ORImage {
    NSString *_UUID;
}

// This was the bit that caught me the most, you have to use a FIC generated string here, not your own

- (NSString *)UUID
{
    if (_UUID == nil) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(self.filename);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    return _UUID;

}

// This is the could change per object one, e.g. 1 profile object with potentially many avatars over time

- (NSString *)sourceImageUUID
{
    return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return [[NSBundle mainBundle] URLForResource:self.filename withExtension:@"jpg"];
}

// If you want default behavior I think you have to do this

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        
        UIGraphicsPushContext(context);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}



@end
