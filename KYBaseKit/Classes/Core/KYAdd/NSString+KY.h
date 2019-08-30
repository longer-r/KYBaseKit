///
//  UIColor+YK.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <Foundation/Foundation.h>
#import "KYVersionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (KY)

/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
- (NSString *)ky_stringByURLEncode;

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)ky_stringByURLDecode;

/**
 Escape common HTML to Entity.
 Example: "a < b" will be escape to "a&lt;b".
 */
- (NSString *)ky_stringByEscapingHTML;


- (NSString *)ky_stringByUnescapeHTML;

#pragma mark - 绘制相关（Drawing）
///=============================================================================
/// @name 绘制相关（Drawing）
///=============================================================================

/**
 获取字符串在指定约束下绘制的size大小。
 Returns the size of the string if it were rendered with the specified constraints.
 
 @param font          The font to use for computing the string size.
 
 @param size          The maximum acceptable size for the string. This value is
 used to calculate where line breaks and wrapping would occur.
 
 @param lineBreakMode The line break options for computing the size of the string.
 For a list of possible values, see NSLineBreakMode.
 
 @return              The width and height of the resulting string's bounding box.
 These values may be rounded up to the nearest whole number.
 */
- (CGSize)ky_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

/**
 获取字符串在指定约束下绘制的size大小
 */
- (CGSize)ky_sizeWithFont:(UIFont *)font width:(CGFloat)width;

/**
 获取字符串在指定约束下绘制的size大小
 */
- (CGSize)ky_sizeWithFont:(UIFont *)font height:(CGFloat)height;

/**
 获取字符串使用指定字体绘制在单行的宽度
 Returns the width of the string if it were to be rendered with the specified
 font on a single line.
 
 @param font  The font to use for computing the string width.
 
 @return      The width of the resulting string's bounding box. These values may be
 rounded up to the nearest whole number.
 */
- (CGFloat)ky_widthForFont:(UIFont *)font;

/**
 获取字符串在指定约束下绘制的高度
 Returns the height of the string if it were rendered with the specified constraints.
 
 @param font   The font to use for computing the string size.
 
 @param width  The maximum acceptable width for the string. This value is used
 to calculate where line breaks and wrapping would occur.
 
 @return       The height of the resulting string's bounding box. These values
 may be rounded up to the nearest whole number.
 */
- (CGFloat)ky_heightForFont:(UIFont *)font width:(CGFloat)width;



#pragma mark - 正则表达式（Regular Expression）
///=============================================================================
/// @name 正则表达式（Regular Expression）
///=============================================================================

/**
 判断是否可以匹配正则
 
 @param regex		正则表达式
 @param options     匹配选项，支持位运算， 参考 NSRegularExpressionOptions。
 @return 可以匹配返回 YES；否则，返回 NO。
 */
- (BOOL)ky_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

/**
 匹配正则表达式，并针对每一个匹配结果执行block
 Match the regular expression, and executes a given block using each object in the matches.
 
 @param regex    The regular expression
 @param options  The matching options to report.
 @param block    The block to apply to elements in the array of matches.
 The block takes four arguments:
 match: The match substring.
 matchRange: The matching options.
 stop: A reference to a Boolean value. The block can set the value
 to YES to stop further processing of the array. The stop
 argument is an out-only argument. You should only ever set
 this Boolean to YES within the Block.
 */
- (void)ky_enumerateRegexMatches:(NSString *)regex
					  options:(NSRegularExpressionOptions)options
				   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;

/**
 使用正则匹配替换字符串，并返回替换后的字符串
 Returns a new string containing matching regular expressions replaced with the template string.
 
 @param regex       The regular expression
 @param options     The matching options to report.
 @param replacement The substitution template used when replacing matching instances.
 
 @return A string with matching regular expressions replaced by the template string.
 */
- (NSString *)ky_stringByReplacingRegex:(NSString *)regex
							 options:(NSRegularExpressionOptions)options
						  withString:(NSString *)replacement;
/**
 判断是否手机号码
 */
- (BOOL)ky_isTelephone;

/**
 判断是否用户名，大小字母＋数字组合，长度3-20
 */
- (BOOL)ky_isUserName;

/**
 判断是否中文用户名，大小字母＋数组＋中文组合，长度3-20
 */
- (BOOL)ky_isChineseUserName;

/**
 判断是否密码，大小写字谜＋数字组合，长度6-20
 */
- (BOOL)ky_isPassword;

/**
 判断是否邮箱地址
 */
- (BOOL)ky_isEmail;

/**
 判断是否url地址
 */
- (BOOL)ky_isUrl;

/**
 判断是否IP地址
 */
- (BOOL)ky_isIPAddress;

#pragma mark - 数值转换（NSNumber Compatible）
///=============================================================================
/// @name 数值转换（NSNumber Compatible）
///=============================================================================

// Now you can use NSString as a NSNumber.
@property (readonly) char ky_charValue;
@property (readonly) unsigned char ky_unsignedCharValue;
@property (readonly) short ky_shortValue;
@property (readonly) unsigned short ky_unsignedShortValue;
@property (readonly) unsigned int ky_unsignedIntValue;
@property (readonly) long ky_longValue;
@property (readonly) unsigned long ky_unsignedLongValue;
@property (readonly) unsigned long long ky_unsignedLongLongValue;
@property (readonly) NSUInteger ky_unsignedIntegerValue;
@property (readonly) KYOperatingVersion ky_versionNumber;

#pragma mark - URL解析（URL Paraser）
/**
 获取url参数
 @param url 包含参数的Url地址
 @param param 要获取的参数名
 */
+ (NSString *)ky_urlParamValue:(NSString *)url param:(NSString *)param;

/**
 将url query转换成dictionary
 */
- (NSDictionary*)ky_urlStringQueryDictionary;

/**
 移除url请求参数
 */
- (NSString *)ky_urlStringByRemovingQuery;


#pragma mark - 工具（Utilities）
///=============================================================================
/// @name 工具（Utilities）
///=============================================================================

/**
 Returns a new UUID NSString
 e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"
 */
+ (NSString *)ky_stringWithUUID;

/**
 Return a new NSString not nil.
 */
+ (NSString *)ky_notNilString:(id)value;

/**
 Returns a string containing the characters in a given UTF32Char.
 
 @param char32 A UTF-32 character.
 @return A new string, or nil if the character is invalid.
 */
+ (nullable NSString *)ky_stringWithUTF32Char:(UTF32Char)char32;

/**
 Returns a string containing the characters in a given UTF32Char array.
 
 @param char32 An array of UTF-32 character.
 @param length The character count in array.
 @return A new string, or nil if an error occurs.
 */
+ (nullable NSString *)ky_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length;

/**
 Enumerates the unicode characters (UTF-32) in the specified range of the string.
 
 @param range The range within the string to enumerate substrings.
 @param block The block executed for the enumeration. The block takes four arguments:
 char32: The unicode character.
 range: The range in receiver. If the range.length is 1, the character is in BMP;
 otherwise (range.length is 2) the character is in none-BMP Plane and stored
 by a surrogate pair in the receiver.
 stop: A reference to a Boolean value that the block can use to stop the enumeration
 by setting *stop = YES; it should not touch *stop otherwise.
 */
//- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block;


/**
 Trim blank characters (space and newline) in head and tail.
 @return the trimmed string.
 */
- (NSString *)ky_stringByTrim;

/**
 Add scale modifier to the file name (without path extension),
 From @"name" to @"name@2x".
 
 e.g.
 <table>
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><ty>"icon"     </ty><ty>"icon@2x"     </ty></tr>
 <tr><ty>"icon "    </ty><ty>"icon @2x"    </ty></tr>
 <tr><ty>"icon.top" </ty><ty>"icon.top@2x" </ty></tr>
 <tr><ty>"/p/name"  </ty><ty>"/p/name@2x"  </ty></tr>
 <tr><ty>"/path/"   </ty><ty>"/path/"      </ty></tr>
 </table>
 
 @param scale Resource scale.
 @return String by add scale modifier, or just return if it's not end with file name.
 */
- (NSString *)ky_stringByAppendingNameScale:(CGFloat)scale;

/**
 Add scale modifier to the file path (with path extension),
 From @"name.png" to @"name@2x.png".
 
 e.g.
 <table>
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><ty>"icon.png" </ty><ty>"icon@2x.png" </ty></tr>
 <tr><ty>"icon..png"</ty><ty>"icon.@2x.png"</ty></tr>
 <tr><ty>"icon"     </ty><ty>"icon@2x"     </ty></tr>
 <tr><ty>"icon "    </ty><ty>"icon @2x"    </ty></tr>
 <tr><ty>"icon."    </ty><ty>"icon.@2x"    </ty></tr>
 <tr><ty>"/p/name"  </ty><ty>"/p/name@2x"  </ty></tr>
 <tr><ty>"/path/"   </ty><ty>"/path/"      </ty></tr>
 </table>
 
 @param scale Resource scale.
 @return String by add scale modifier, or just return if it's not end with file name.
 */
- (NSString *)ky_stringByAppendingPathScale:(CGFloat)scale;

/**
 Return the path scale.
 
 e.g.
 <table>
 <tr><th>Path            </th><th>Scale </th></tr>
 <tr><ty>"icon.png"      </ty><ty>1     </ty></tr>
 <tr><ty>"icon@2x.png"   </ty><ty>2     </ty></tr>
 <tr><ty>"icon@2.5x.png" </ty><ty>2.5   </ty></tr>
 <tr><ty>"icon@2x"       </ty><ty>1     </ty></tr>
 <tr><ty>"icon@2x..png"  </ty><ty>1     </ty></tr>
 <tr><ty>"icon@2x.png/"  </ty><ty>1     </ty></tr>
 </table>
 */
- (CGFloat)ky_pathScale;

/**
 nil, @"", @"  ", @"\n" will Returns NO; otherwise Returns YES.
 */
- (BOOL)ky_isNotBlank;

/**
 判断字符串是否是 nil 或 @""，如果是返回 YES；否则返回 NO
 */
+ (BOOL)ky_isEmpty:(NSString *)string;

/**
 与 `ky_isEmpty：`相反
 */
+ (BOOL)ky_isNotEmpty:(NSString *)string;

/**
 Returns YES if the target string is contained within the receiver.
 @param string A string to test the the receiver.
 
 @discussion Apple has implemented this method in iOS8.
 */
- (BOOL)ky_containsString:(NSString *)string;

/**
 判断是否包含字符串 `string` ，如果包含返回 YES，否则返回 NO。
 
 @param string		待检测的字符串
 @param caseInsens	检测过程是否忽略大小写
 */
- (BOOL)ky_containsString:(NSString *)string caseInsens:(BOOL)caseInsens;

/**
 Returns YES if the target CharacterSet is contained within the receiver.
 @param set  A character set to test the the receiver.
 */
- (BOOL)ky_containsCharacterSet:(NSCharacterSet *)set;

/**
 Try to parse this string and returns an `NSNumber`.
 @return Returns an `NSNumber` if parse succeed, or nil if an error occurs.
 */
- (nullable NSNumber *)ky_numberValue;

/**
 Returns an NSData using UTF-8 encoding.
 */
- (nullable NSData *)ky_dataValue;

/**
 返回一个NSURL实体
 */
- (nullable NSURL *)ky_urlValue;

/**
 Returns NSMakeRange(0, self.length).
 */
- (NSRange)ky_rangeOfAll;

/**
 Create a string from the file in main bundle (similar to [UIImage imageNamed:]).
 
 @param name The file name (in main bundle).
 
 @return A new string create from the file in UTF-8 character encoding.
 */
+ (nullable NSString *)ky_stringNamed:(NSString *)name;

/**
 * 获取字符串长度
 * 中文为1个字符
 * 英文为0.5个字符
 */
- (CGFloat)ky_unicodeLength;
- (CGFloat)ky_unicodeLength:(NSUInteger)maxLength out_rangeLength:(NSUInteger *)out_rangeLength;

/**
 * Removed string's char by range
 */
//- (NSString *)ky_stringByRemovedRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
