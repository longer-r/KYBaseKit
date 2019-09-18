//
//  UIColor+YK.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//



NS_ASSUME_NONNULL_BEGIN

extern void KY_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *h, CGFloat *s, CGFloat *l);

extern void KY_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                        CGFloat *r, CGFloat *g, CGFloat *b);

extern void KY_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *h, CGFloat *s, CGFloat *v);

extern void KY_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                        CGFloat *r, CGFloat *g, CGFloat *b);

extern void KY_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                         CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

extern void KY_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                         CGFloat *r, CGFloat *g, CGFloat *b);

extern void KY_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                        CGFloat *hh, CGFloat *ss, CGFloat *ll);

extern void KY_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                        CGFloat *hh, CGFloat *ss, CGFloat *bb);


/*
 Create UIColor with a hex string.
 Example: KY_UIColorHex(0xF0F), KY_UIColorHex(66ccff), KY_UIColorHex(#66CCFF88)
 
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 */
#ifndef KY_UIColorHex
#define KY_UIColorHex(_hex_)   [UIColor ky_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

//十六进制颜色
#define KY_UIColorHex_Alpha(_hex_, a) [UIColor colorWithRed:((_hex_ >> 16) & 0x000000FF)/255.0f            \
green:((_hex_ >> 8) & 0x000000FF)/255.0f    \
blue:((_hex_) & 0x000000FF)/255.0f            \
alpha:a]
//RGBA颜色
#define KY_UIColorRGBA(r,g,b,a)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 Provide some method for `UIColor` to convert color between
 RGB,HSB,HSL,CMYK and Hex.
 
 | Color space | Meaning                                |
 |-------------|----------------------------------------|
 | RGB *       | Red, Green, Blue                       |
 | HSB(HSV) *  | Hue, Saturation, Brightness (Value)    |
 | HSL         | Hue, Saturation, Lightness             |
 | CMYK        | Cyan, Magenta, Yellow, Black           |
 
 Apple use RGB & HSB default.
 
 All the value in this category is float number in the range `0.0` to `1.0`.
 Values below `0.0` are interpreted as `0.0`,
 and values above `1.0` are interpreted as `1.0`.
 
 If you want convert color between more color space (CIEXYZ,Lab,YUV...),
 see https://github.com/ibireme/yy_color_convertor
 */
@interface UIColor (KY)


#pragma mark - Create a UIColor Object
///=============================================================================
/// @name Creating a UIColor Object
///=============================================================================

/**
 Creates and returns a color object using the specified opacity
 and HSL color space component values.
 
 @param hue        The hue component of the color object in the HSL color space,
 specified as a value from 0.0 to 1.0.
 
 @param saturation The saturation component of the color object in the HSL color space,
 specified as a value from 0.0 to 1.0.
 
 @param lightness  The lightness component of the color object in the HSL color space,
 specified as a value from 0.0 to 1.0.
 
 @param alpha      The opacity value of the color object,
 specified as a value from 0.0 to 1.0.
 
 @return           The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)ky_colorWithHue:(CGFloat)hue
                   saturation:(CGFloat)saturation
                    lightness:(CGFloat)lightness
                        alpha:(CGFloat)alpha;

/**
 Creates and returns a color object using the specified opacity
 and CMYK color space component values.
 
 @param cyan    The cyan component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param magenta The magenta component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param yellow  The yellow component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param black   The black component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param alpha   The opacity value of the color object,
 specified as a value from 0.0 to 1.0.
 
 @return        The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)ky_colorWithCyan:(CGFloat)cyan
                       magenta:(CGFloat)magenta
                        yellow:(CGFloat)yellow
                         black:(CGFloat)black
                         alpha:(CGFloat)alpha;

/**
 Creates and returns a color object using the hex RGB color values.
 
 @param rgbValue  The rgb value such as 0x66ccff.
 
 @return          The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)ky_colorWithRGB:(uint32_t)rgbValue;

/**
 Creates and returns a color object using the hex RGBA color values.
 
 @param rgbaValue  The rgb value such as 0x66ccffff.
 
 @return           The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)ky_colorWithRGBA:(uint32_t)rgbaValue;

/**
 Creates and returns a color object using the specified opacity and RGB hex value.
 
 @param rgbValue  The rgb value such as 0x66CCFF.
 
 @param alpha     The opacity value of the color object,
 specified as a value from 0.0 to 1.0.
 
 @return          The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)ky_colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

/**
 Creates and returns a color object from hex string.
 
 @discussion:
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 The alpha will be set to 1.0 if there is no alpha component.
 It will return nil when an error occurs in parsing.
 
 Example: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  The hex string value for the new color.
 
 @return        An UIColor object from string, or nil if an error occurs.
 */
+ (nullable UIColor *)ky_colorWithHexString:(NSString *)hexStr;

/**
 Creates and returns a color object by add new color.
 
 @param add        the color added
 
 @param blendMode  add color blend mode
 */
- (UIColor *)ky_colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

/**
 Creates and returns a color object by change components.
 
 @param hueDelta         the hue change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param saturationDelta  the saturation change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param brightnessDelta  the brightness change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param alphaDelta       the alpha change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 */
- (UIColor *)ky_colorByChangeHue:(CGFloat)hueDelta
                       saturation:(CGFloat)saturationDelta
                       brightness:(CGFloat)brightnessDelta
                            alpha:(CGFloat)alphaDelta;


#pragma mark - Get color's description
///=============================================================================
/// @name Get color's description
///=============================================================================

/**
 Returns the rgb value in hex.
 @return hex value of RGB,such as 0x66ccff.
 */
- (uint32_t)ky_rgbValue;

/**
 Returns the rgba value in hex.
 
 @return hex value of RGBA,such as 0x66ccffff.
 */
- (uint32_t)ky_rgbaValue;

/**
 Returns the color's RGB value as a hex string (lowercase).
 Such as @"0066cc".
 
 It will return nil when the color space is not RGB
 
 @return The color's value as a hex string.
 */
- (nullable NSString *)ky_hexString;

/**
 Returns the color's RGBA value as a hex string (lowercase).
 Such as @"0066ccff".
 
 It will return nil when the color space is not RGBA
 
 @return The color's value as a hex string.
 */
- (nullable NSString *)ky_hexStringWithAlpha;


#pragma mark - Retrieving Color Information
///=============================================================================
/// @name Retrieving Color Information
///=============================================================================

/**
 Returns the components that make up the color in the HSL color space.
 
 @param hue         On return, the hue component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param saturation  On return, the saturation component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param lightness   On return, the lightness component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param alpha       On return, the alpha component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @return            YES if the color could be converted, NO otherwise.
 */
- (BOOL)ky_getHue:(CGFloat *)hue
        saturation:(CGFloat *)saturation
         lightness:(CGFloat *)lightness
             alpha:(CGFloat *)alpha;

/**
 Returns the components that make up the color in the CMYK color space.
 
 @param cyan     On return, the cyan component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param magenta  On return, the magenta component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param yellow   On return, the yellow component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param black    On return, the black component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param alpha    On return, the alpha component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @return         YES if the color could be converted, NO otherwise.
 */
- (BOOL)ky_getCyan:(CGFloat *)cyan
            magenta:(CGFloat *)magenta
             yellow:(CGFloat *)yellow
              black:(CGFloat *)black
              alpha:(CGFloat *)alpha;

/**
 The color's red component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_red;

/**
 The color's green component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_green;

/**
 The color's blue component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_blue;

/**
 The color's hue component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_hue;

/**
 The color's saturation component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_saturation;

/**
 The color's brightness component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_brightness;

/**
 The color's alpha component value.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat ky_alpha;

/**
 The color's colorspace model.
 */
@property (nonatomic, readonly) CGColorSpaceModel ky_colorSpaceModel;

/**
 Readable colorspace string.
 */
@property (nullable, nonatomic, readonly) NSString *ky_colorSpaceString;

@end

NS_ASSUME_NONNULL_END

