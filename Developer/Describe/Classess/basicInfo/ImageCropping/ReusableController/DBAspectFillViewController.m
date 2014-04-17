//
//  DBViewController.m
//  AspectFillImage
//
//  Created by Describe Administrator on 16/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "DBAspectFillViewController.h"

#define MIN_ZOOMSCALE           1.0f
#define MAX_ZOOMSCALE           2.0f

@interface DBAspectFillViewController ()

//@property (strong, nonatomic, readonly) UIImage *editedImage;

@end

@implementation DBAspectFillViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _screenSize = [[UIScreen mainScreen] bounds].size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableTouches:(BOOL)enable
{
    _imageContentScrollView.scrollEnabled = enable;
    _imageContentScrollView.maximumZoomScale = enable ? MAX_ZOOMSCALE : MIN_ZOOMSCALE;
}

- (void)resetImageContentToEmpty
{
    _imageView.image = nil;
    _cropRect = CGRectNull;
    [_imageContentScrollView setContentOffset:CGPointZero animated:NO];
    [_imageContentScrollView setZoomScale:1.0f animated:NO];
}

- (void)loadImageFromURLString:(NSString *)urlString
{
    [_imageView setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        [self placeSelectedImage:image withCropRect:CGRectNull];
        if(error == nil) {
            _imageView.image = image;
        }
    }];
}

- (void)placeSelectedImage:(UIImage *)image withCropRect:(CGRect)cropRect
{
    [self resetImageContentToEmpty];
    
    if(image == nil) {
        return;
    }
       
//    UIImage *correctOrientationImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
    
    CGSize imageSize = image.size;
    
    // check if image width & height both are of atleast screenSize, if not
    // then find ratio of image width to height, so increase either of them or both to satisfy screenSize and fulfill
    // AspectFill effect
    // step 1: Check image width & height with screenSize
//    if(imageSize.width < _screenSize.width || imageSize.height < _screenSize.height) {
        // find x calcualtion factor and y factor too
        CGFloat xFactor = imageSize.width/imageSize.height;
        CGFloat yFactor = imageSize.height/imageSize.width;
        
        CGSize newImgSize = imageSize;
        // identify out of width & height which is less
        if(imageSize.width < imageSize.height) {
            // width is less
            newImgSize.width = _screenSize.width;// * 2.0f;
            newImgSize.height = _screenSize.width * yFactor;// * 2.0f;
        }
        else {
            // height is less
            newImgSize.height = _screenSize.height;// * 2.0f;
            newImgSize.width = _screenSize.height * xFactor;// * 2.0f;
        }
        
        imageSize.width = newImgSize.width;///2.0f;
        imageSize.height = newImgSize.height;///2.0f;
        image = [self imageWithImage:image scaledToSize:newImgSize];
//    }
    
    CGRect imageViewRect = _imageView.frame;
    imageViewRect.size = imageSize;
    _imageView.frame = imageViewRect;
    
    _imageView.image = image;
    
    _imageContentScrollView.contentSize = imageSize;
    
    if(!CGRectIsNull(cropRect)) {
        [_imageContentScrollView zoomToRect:cropRect animated:NO];
    }
    else {
        // find contentOffset for bringing center of image into visible area
        CGFloat xVal = imageSize.width/2.0f - CGRectGetWidth(_imageContentScrollView.frame)/2.0f;
        CGFloat yVal = imageSize.height/2.0f - CGRectGetHeight(_imageContentScrollView.frame)/2.0f;
        [_imageContentScrollView setContentOffset:CGPointMake(xVal, yVal) animated:NO];
        
        [self calculateCropRectForSelectImage];
    }
    
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //    NSLog(@"%s", __func__);
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //    NSLog(@"%s", __func__);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    //    NSLog(@"%s", __func__);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self calculateCropRectForSelectImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"%s", __func__);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate == NO) {
        [self calculateCropRectForSelectImage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self calculateCropRectForSelectImage];
}

#pragma mark - Calculate crop rect

- (void)calculateCropRectForSelectImage
{
    // check if image is selected for editing
    if(_imageView.image) {
//        NSLog(@"%s", __func__);
//        NSLog(@"ScrollView ContentOffset = %@", NSStringFromCGPoint(_imageContentScrollView.contentOffset));
//        NSLog(@"ScrollView ContentSize = %@", NSStringFromCGSize(_imageContentScrollView.contentSize));
//        NSLog(@"Scale = %f", _imageContentScrollView.zoomScale);
//        NSLog(@"View = %@", _imageView);
//        NSLog(@"View = %@", NSStringFromCGSize(_imageView.image.size));
        
        // Here we will try to find the crop rect of the selected image with respect to the original image.
        // the logic here is to check the zoomscale of scrollview. then using zoomscale value
        // 1. we will find the x, y value for crop rect with respect to contentoffset of scrollview
        // 2. we will find the width, height value for crop rect with respect to width and height of selectedImageView
        
        CGFloat zoomScale = _imageContentScrollView.zoomScale;
        
        // Step1: Find x and y value using contentOffset of scrollview
        CGFloat xVal = _imageContentScrollView.contentOffset.x/zoomScale;
        CGFloat yVal = _imageContentScrollView.contentOffset.y/zoomScale;
        
        // Step2: Find width and height value
        CGFloat widthVal = CGRectGetWidth(_imageContentScrollView.frame)/zoomScale;
        CGFloat heightVal = CGRectGetHeight(_imageContentScrollView.frame)/zoomScale;
        
        _cropRect = CGRectMake(xVal, yVal, widthVal, heightVal);
        
        NSLog(@"cropRect = %@", NSStringFromCGRect(_cropRect));
        
//        [self setCropRect:cropRect];
        if(_delegate != nil && [_delegate respondsToSelector:@selector(imageDidZoomToRect:)]) {
            [_delegate imageDidZoomToRect:_cropRect];
        }
    }
}

- (UIImage *)getImageCroppedAtVisibleRect:(CGRect)visibleCropRect
{
    UIImage *croppedImage = nil;
    if(_imageView.image) {
        CGImageRef imgRef = CGImageCreateWithImageInRect(_imageView.image.CGImage, visibleCropRect);
        croppedImage = [UIImage imageWithCGImage:imgRef];
    }
    
    return croppedImage;
}

/*
- (void)setCropRect:(CGRect)rect
{
    _cropRect = rect;
    
    if(_imageView.image) {
        CGImageRef imgRef = CGImageCreateWithImageInRect(_imageView.image.CGImage, _cropRect);
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        _editedImage = image;
    }
}
 */

@end
