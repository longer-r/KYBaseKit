//
//  UIImage+KY.m
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import "UIImage+KY.h"
#import <CoreText/CoreText.h>
#import "KYBaseMacro.h"

KYSYNTH_DUMMY_CLASS(UIImage_YK)
@implementation UIImage (KY)

#pragma mark - 图片生成

+ (UIImage *)ky_imageWithEmoji:(NSString *)emoji size:(CGFloat)size {
    if (emoji.length == 0) return nil;
    if (size < 1) return nil;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CTFontRef font = CTFontCreateWithName(CFSTR("AppleColorEmoji"), size * scale, NULL);
    if (!font) return nil;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:emoji attributes:@{ (__bridge id)kCTFontAttributeName:(__bridge id)font, (__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor whiteColor].CGColor }];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, size * scale, size * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFTypeRef)str);
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
    CGContextSetTextPosition(ctx, 0, -bounds.origin.y);
    CTLineDraw(line, ctx);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
    CFRelease(font);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    if (line)CFRelease(line);
    if (imageRef) CFRelease(imageRef);
    
    return image;
}


#pragma mark - Compress

- (UIImage *)ky_compressToRatio:(CGFloat)ratio {
    return [self ky_compressToRatio:ratio maxCompressRatio:0.1f minResolution:(1136 * 640) maxSize:50];
}

- (UIImage *)ky_compressToRatio:(CGFloat)ratio minResolution:(NSInteger)minResolution maxSize:(NSInteger)maxSize {
    return [self ky_compressToRatio:ratio maxCompressRatio:0.1f minResolution:minResolution maxSize:maxSize];
}

- (UIImage *)ky_compressToRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio
                   minResolution:(NSInteger)minResolution maxSize:(NSInteger)maxSize {
    
    UIImage *image = self;
    
    //We define the max and min resolutions to shrink to
    NSInteger MIN_UPLOAD_RESOLUTION = minResolution;
    NSInteger MAX_UPLOAD_SIZE = maxSize;
    
    float factor;
    float currentResolution = image.size.height * image.size.width;
    
    //We first shrink the image a little bit in order to compress it a little bit more
    if (currentResolution > MIN_UPLOAD_RESOLUTION) {
        factor = sqrt(currentResolution / MIN_UPLOAD_RESOLUTION) * 2;
        image = [self ky_scaleDownWithSize:CGSizeMake(image.size.width / factor, image.size.height / factor)];
    }
    
    //Compression settings
    CGFloat compression = ratio;
    CGFloat maxCompression = maxRatio;
    
    //We loop into the image data to compress accordingly to the compression ratio
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxCompression) {
        compression -= 0.10;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //Retuns the compressed image
    return [[UIImage alloc] initWithData:imageData];
}


- (UIImage*)ky_scaleDownWithSize:(CGSize)newSize {
    
    //We prepare a bitmap with the new size
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    
    //Draws a rect for the image
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //We set the scaled image from the context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [scaledImage ky_fixOrientation];
}

- (UIImage *)ky_fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


#pragma mark -

- (unsigned char *)pixelBGR24Bytes {
    
    CGImageRef imageRef = self.CGImage;
    
    size_t iWidth = CGImageGetWidth(imageRef);
    size_t iHeight = CGImageGetHeight(imageRef);
    size_t iBytesPerPixel = 4;
    size_t iBytesPerRow = iBytesPerPixel * iWidth;
    size_t iBitsPerComponent = 8;
    unsigned char *imageBytes = malloc(iWidth * iHeight * iBytesPerPixel);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(imageBytes,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,imageRef);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    unsigned char * bgr24 = malloc(iWidth * iHeight * 3);
    unsigned char * pScr = imageBytes;
    unsigned char * pDst = bgr24 + iWidth*(iHeight - 1)*3;
    size_t lines2 = iWidth * 3 * 2;
    for (size_t y = 0; y < iHeight; y++) {
        for (size_t x = 0; x < iWidth; x++) {
            pDst[0] = pScr[2];
            pDst[1] = pScr[1];
            pDst[2] = pScr[0];
            pDst+=3;
            pScr+=4;
        }
        pDst -= lines2;
    }
    
    /* for (size_t y = 0; y < iHeight; y++) {
     for (size_t x = 0; x < iWidth; x++) {
     size_t pixelIndex = y * iWidth * 4 + x * 4;
     unsigned char red = imageBytes[pixelIndex];
     unsigned char green = imageBytes[pixelIndex + 1];
     unsigned char blue = imageBytes[pixelIndex + 2];
     //            NSLog(@"red=%d green=%d blue=%d",red , green, blue);
     
     size_t bgr24pixelIndex = y * iWidth * 3 + x * 3;
     bgr24[bgr24pixelIndex] = blue;
     bgr24[bgr24pixelIndex + 1] = green;
     bgr24[bgr24pixelIndex + 2] = red;
     //            NSLog(@"blue=%d green=%d red=%d",bgr24[bgr24pixelIndex] , bgr24[bgr24pixelIndex + 1], bgr24[bgr24pixelIndex + 2]);
     }
     }*/
    free(imageBytes);
    return bgr24;
}



@end
