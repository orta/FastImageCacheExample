//
//  ORImage.h
//  FastImageCacheExample
//
//  Created by Orta on 4/21/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FastImageCache/FICImageCache.h>

extern NSString *const FICDPhotoSquareImage16BitBGRFormatName;
extern NSString *const FICDPhotoImageFormatFamily;

extern CGSize const FICDPhotoSquareImageSize;

@interface ORImage : NSObject <FICEntity>

@property (nonatomic, copy) NSString *filename;

@end
