//
//  UIImage+KY.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KY)


#pragma mark - 图片生成
///=============================================================================
/// @name 图片生成
///=============================================================================

/**
 Create a square image from apple emoji.
 
 @discussion It creates a square image from apple emoji, image's scale is equal
 to current screen's scale. The original emoji image in `AppleColorEmoji` font
 is in size 160*160 px.
 
 @param emoji single emoji, such as @"😄".
 
 @param size  image's size.
 
 @return Image from emoji, or nil when an error occurs.
 */
+ (nullable UIImage *)ky_imageWithEmoji:(NSString *)emoji size:(CGFloat)size;


#pragma mark - 图片压缩
///=============================================================================
/// @name 图片压缩
///=============================================================================


/**
 * 将图片压缩到一定的比例
 *
 * @param ratio 压缩比
 *
 * @return 压缩后的图片
 *
 */
- (UIImage *)ky_compressToRatio:(CGFloat)ratio;


/**
 * 将图片压缩到一定的比例
 *
 * @param ratio 压缩比
 * @param minResolution 最小缩放
 * @param maxSize 最大size
 *
 * @return 压缩后的图片
 *
 */
- (UIImage *)ky_compressToRatio:(CGFloat)ratio
                   minResolution:(NSInteger)minResolution maxSize:(NSInteger)maxSize;


/**
 * 将图片压缩到一定的比例，并制定最大压缩比
 *
 * @param ratio 压缩比
 * @param maxRatio 最大压缩比
 * @param minResolution 最小缩放
 * @param maxSize 最大size
 *
 * @return 压缩后的图片
 *
 */
- (UIImage *)ky_compressToRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio
                   minResolution:(NSInteger)minResolution maxSize:(NSInteger)maxSize;

/**
 * 讲图片缩放到指定尺寸
 *
 * @param newSize 尺寸
 *
 * @return 缩小后的图片
 *
 */
- (UIImage*)ky_scaleDownWithSize:(CGSize)newSize;


/**
 * Fix Image orientation
 */
- (UIImage *)ky_fixOrientation;


#pragma mark - Cover

- (unsigned char *)pixelBGR24Bytes;


@end

NS_ASSUME_NONNULL_END
