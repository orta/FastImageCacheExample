FastImageCacheExample
=====================

The simplest possible use of FastImageCache

I didn't write [FastImageCache](https://github.com/path/FastImageCache).

### Overall

Setup the `FICImageCache` somewhere, an easy place to start it App Delegate

```
    // Configure the image cache
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setDelegate:self];

    // Reuse the Path image formats
    FICImageFormatDevices squareImageFormatDevices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    FICImageFormat *squareImageFormat16BitBGR = [FICImageFormat formatWithName:FICDPhotoSquareImage16BitBGRFormatName family:FICDPhotoImageFormatFamily
                                                                     imageSize:FICDPhotoSquareImageSize style:FICImageFormatStyle16BitBGR
                                                                  maximumCount:250 devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
    
    [sharedImageCache setFormats:@[squareImageFormat16BitBGR]];
```

Wherever this class is it needs to do the work of connecting an <FICEntity> to a UIImage. 
	
```
- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSURL *filePathURL = [entity sourceImageURLWithFormatName:formatName];        
        UIImage *sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePathURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}

```

You have to include the other methods, these will probably come in useful later:

```

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity {
    return NO;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage {
    NSLog(@"%@", errorMessage);
}

```

You now need an object that conforms to the `<FICEntity>` protocol. Here's a gotcha for me. _The UUIDs have to go through `FICUUIDBytesFromMD5HashOfString` & `FICStringWithUUIDBytes` before they get matched correctly, if they don't it will silently not find your image._
	
```
@interface ORImage : NSObject <FICEntity>

@property (nonatomic, copy) NSString *filename;

@end
```

You can't skip `drawingBlockForImage:withFormatName:` even if you're just redrawing the image.

```
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

```

Next you need to make sure you have your image table formats set up correctly, I reused more of Paths:

```
NSString *const FICDPhotoImageFormatFamily = @"FICDPhotoImageFormatFamily";
NSString *const FICDPhotoSquareImage16BitBGRFormatName = @"com.path.FastImageCacheDemo.FICDPhotoSquareImage16BitBGRFormatName";
CGSize const FICDPhotoSquareImageSize = {240, 240};
```

and 

```
extern NSString *const FICDPhotoSquareImage16BitBGRFormatName;
extern NSString *const FICDPhotoImageFormatFamily;
```

With all this set up you're now ready to call something like this to get an image from the cache:

```
self.image = [[ORImage alloc] init];
self.image.filename = @"pizza";

[[FICImageCache sharedImageCache] retrieveImageForEntity:self.image withFormatName:FICDPhotoSquareImage16BitBGRFormatName completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
    [self.imageView setImage:image];
}];
```

And you've got the first image going through the FIC pipeline, now you build from there.