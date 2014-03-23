//
//  DBViewController.h
//  AspectFillImage
//
//  Created by Describe Administrator on 16/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@protocol DBAspectFillViewControllerDelegate <NSObject>

@optional
- (void)imageDidZoomToRect:(CGRect)cropRect;

@end

@interface DBAspectFillViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) CGSize screenSize;
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, weak) id <DBAspectFillViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *imageContentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

- (void)placeSelectedImage:(UIImage *)image withCropRect:(CGRect)cropRect;
- (void)resetImageContentToEmpty;
- (void)enableTouches:(BOOL)enable;
- (void)calculateCropRectForSelectImage;
- (UIImage *)getImageCroppedAtVisibleRect:(CGRect)visibleCropRect;
- (void)loadImageFromURLString:(NSString *)urlString;

@end
