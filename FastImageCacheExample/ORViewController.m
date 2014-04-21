//
//  ORViewController.m
//  FastImageCacheExample
//
//  Created by Orta on 4/21/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORViewController.h"
#import "ORImage.h"
#import <FastImageCache/FICImageCache.h>

@interface ORViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong) ORImage *image;

@end

@implementation ORViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.image = [[ORImage alloc] init];
    self.image.filename = @"pizza";
    
    [[FICImageCache sharedImageCache] retrieveImageForEntity:self.image withFormatName:FICDPhotoSquareImage16BitBGRFormatName completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        [self.imageView setImage:image];
    }];
    
    NSLog(@"loaded");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
