//
//  NSString+KY.m
//  KY
//
//  Created by tuyongbin on 19/3/28.
//  Copyright © 2016年 Tandy. All rights reserved.
//

#import "NSString+KY.h"
#import "NSNumber+KY.h"
#import "KYBaseMacro.h"

KYSYNTH_DUMMY_CLASS(NSString_KY)

@implementation NSString (KY)

- (NSString *)ky_stringByURLEncode {
	if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
		/**
		 AFNetworking/AFURLRequestSerialization.m
		 
		 Returns a percent-escaped string following RFC 3986 for a query string key or value.
		 RFC 3986 states that the following characters are "reserved" characters.
		 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
		 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
		 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
		 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
		 should be percent-escaped in the query string.
		 - parameter string: The string to be percent-escaped.
		 - returns: The percent-escaped string.
		 */
		static NSString * const TD_kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
		static NSString * const TD_kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
		
		NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
		[allowedCharacterSet removeCharactersInString:[TD_kAFCharactersGeneralDelimitersToEncode stringByAppendingString:TD_kAFCharactersSubDelimitersToEncode]];
		static NSUInteger const batchSize = 50;
		
		NSUInteger index = 0;
		NSMutableString *escaped = @"".mutableCopy;
		
		while (index < self.length) {
			NSUInteger length = MIN(self.length - index, batchSize);
			NSRange range = NSMakeRange(index, length);
			// To avoid breaking up character sequences such as 👴🏻👮🏽
			range = [self rangeOfComposedCharacterSequencesForRange:range];
			NSString *substring = [self substringWithRange:range];
			NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
			[escaped appendString:encoded];
			
			index += range.length;
		}
		return escaped;
	} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		NSString *encoded = (__bridge_transfer NSString *)
		CFURLCreateStringByAddingPercentEscapes(
												kCFAllocatorDefault,
												(__bridge CFStringRef)self,
												NULL,
												CFSTR("!#$&'()*+,/:;=?@[]"),
												cfEncoding);
		return encoded;
#pragma clang diagnostic pop
	}
}

- (NSString *)ky_stringByURLDecode {
	if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
		return [self stringByRemovingPercentEncoding];
	} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
															withString:@" "];
		decoded = (__bridge_transfer NSString *)
		CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
																NULL,
																(__bridge CFStringRef)decoded,
																CFSTR(""),
																en);
		return decoded;
#pragma clang diagnostic pop
	}
}

- (NSString *)ky_stringByEscapingHTML {
	NSUInteger len = self.length;
	if (!len) return self;
	
	unichar *buf = malloc(sizeof(unichar) * len);
	if (!buf) return nil;
	[self getCharacters:buf range:NSMakeRange(0, len)];
	
	NSMutableString *result = [NSMutableString string];
	for (int i = 0; i < len; i++) {
		unichar c = buf[i];
		NSString *esc = nil;
		switch (c) {
			case 34: esc = @"&quot;"; break;
			case 38: esc = @"&amp;"; break;
			case 39: esc = @"&apos;"; break;
			case 60: esc = @"&lt;"; break;
			case 62: esc = @"&gt;"; break;
			default: break;
		}
		if (esc) {
			[result appendString:esc];
		} else {
			CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
		}
	}
	free(buf);
	return result;
}


- (NSString *)ky_stringByUnescapeHTML {
	
	NSMutableString* s = [NSMutableString string];
	NSMutableString* target = [self mutableCopy];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}


#pragma mark - 绘制相关（Drawing）

- (CGSize)ky_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {

	CGSize result;
	if (!font) font = [UIFont systemFontOfSize:12];
	if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
		NSMutableDictionary *attr = [NSMutableDictionary new];
		attr[NSFontAttributeName] = font;
		if (lineBreakMode != NSLineBreakByWordWrapping) {
			NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
			paragraphStyle.lineBreakMode = lineBreakMode;
			attr[NSParagraphStyleAttributeName] = paragraphStyle;
		}
		CGRect rect = [self boundingRectWithSize:size
										 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
									  attributes:attr context:nil];
		result = rect.size;
	} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
	}
	return result;
}

- (CGSize)ky_sizeWithFont:(UIFont *)font width:(CGFloat)width {
	return [self ky_sizeForFont:font size:CGSizeMake(width, HUGE)
						   mode:NSLineBreakByWordWrapping];
}

- (CGSize)ky_sizeWithFont:(UIFont *)font height:(CGFloat)height {
	return [self ky_sizeForFont:font size:CGSizeMake(HUGE, height)
						   mode:NSLineBreakByWordWrapping];
}

- (CGFloat)ky_widthForFont:(UIFont *)font {
	CGSize size = [self ky_sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
	return size.width;
}

- (CGFloat)ky_heightForFont:(UIFont *)font width:(CGFloat)width {
	CGSize size = [self ky_sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
	return size.height;
}

#pragma mark - 正则表达式（Regular Expression）

- (BOOL)ky_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
	NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
	if (!pattern) return NO;
	return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)ky_enumerateRegexMatches:(NSString *)regex
					  options:(NSRegularExpressionOptions)options
				   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
	if (regex.length == 0 || !block) return;
	NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
	if (!regex) return;
	[pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		block([self substringWithRange:result.range], result.range, stop);
	}];
}

- (NSString *)ky_stringByReplacingRegex:(NSString *)regex
							 options:(NSRegularExpressionOptions)options
						  withString:(NSString *)replacement; {
	NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
	if (!pattern) return self;
	return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (BOOL)ky_isTelephone {
	
	//fix: 修改Mobile正则
	NSString * MOBILE = @"^1(3[0-9]|5[0-9]|8[0-9])\\d{8}$";
	NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
	NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
	NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
	NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
	NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
	NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
	NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
	NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
	NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
	
	return  [regextestmobile evaluateWithObject:self]   ||
	[regextestphs evaluateWithObject:self]      ||
	[regextestct evaluateWithObject:self]       ||
	[regextestcu evaluateWithObject:self]       ||
	[regextestcm evaluateWithObject:self];
}

- (BOOL)ky_isUserName {
	NSString *		regex = @"(^[A-Za-z0-9]{3,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)ky_isChineseUserName {
	NSString *		regex = @"(^[A-Za-z0-9\u4e00-\u9fa5]{3,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)ky_isPassword {
	NSString *		regex = @"(^[A-Za-z0-9]{6,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)ky_isEmail {
	NSString *		regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)ky_isUrl {
    static NSPredicate *pred = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
        pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    });
	return [pred evaluateWithObject:self];
}

- (BOOL)ky_isIPAddress {
	NSArray *			components = [self componentsSeparatedByString:@"."];
	NSCharacterSet *	invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
	
	if ( [components count] == 4 )
	{
		NSString *part1 = [components objectAtIndex:0];
		NSString *part2 = [components objectAtIndex:1];
		NSString *part3 = [components objectAtIndex:2];
		NSString *part4 = [components objectAtIndex:3];
		
		if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
			[part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
			[part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
			[part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound )
		{
			if ( [part1 intValue] < 255 &&
				[part2 intValue] < 255 &&
				[part3 intValue] < 255 &&
				[part4 intValue] < 255 )
			{
				return YES;
			}
		}
	}
	
	return NO;
}

#pragma mark - 数值转换（NSNumber Compatible）

- (char)ky_charValue {
	return self.ky_numberValue.charValue;
}

- (unsigned char) ky_unsignedCharValue {
	return self.ky_numberValue.unsignedCharValue;
}

- (short) ky_shortValue {
	return self.ky_numberValue.shortValue;
}

- (unsigned short) ky_unsignedShortValue {
	return self.ky_numberValue.unsignedShortValue;
}

- (unsigned int) ky_unsignedIntValue {
	return self.ky_numberValue.unsignedIntValue;
}

- (long) ky_longValue {
	return self.ky_numberValue.longValue;
}

- (unsigned long) ky_unsignedLongValue {
	return self.ky_numberValue.unsignedLongValue;
}

- (unsigned long long) ky_unsignedLongLongValue {
	return self.ky_numberValue.unsignedLongLongValue;
}

- (NSUInteger) ky_unsignedIntegerValue {
	return self.ky_numberValue.unsignedIntegerValue;
}

- (KYOperatingVersion)ky_versionNumber {
    KYOperatingVersion versionNumber = (KYOperatingVersion){0, 0, 0};
    if (self.length < 1) {
        return versionNumber;
    }
    
    /// 排除可能的beta版本，eg. 5.1.2.a1230
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    if ([oneComponents count] < 1) {
        return versionNumber;
    }
    /// Get main version
    NSString *versionMain = [oneComponents objectAtIndex:0];
    
    /// 排除带前缀的v,V
    if ([versionMain hasPrefix:@"v"] || [versionMain hasPrefix:@"V"]) {
        NSMutableString *mutableString = [versionMain mutableCopy];
        [mutableString deleteCharactersInRange:NSMakeRange(0, 1)];
        versionMain = [mutableString copy];
    }
    
    /// 组合Version
    NSArray *versionArray = [versionMain componentsSeparatedByString:@"."];
    if ([versionArray count] > 0) {
        versionNumber.majorVersion = [[versionArray objectAtIndex:0] integerValue];
    }
    if ([versionArray count] > 1) {
        versionNumber.minorVersion = [[versionArray objectAtIndex:1] integerValue];
    }
    if ([versionArray count] > 2) {
        versionNumber.patchVersion = [[versionArray objectAtIndex:2] integerValue];
    }
    return versionNumber;
}


#pragma mark - URL解析（URL Paraser）

+ (NSString *)ky_urlParamValue:(NSString *)url param:(NSString *)param {

	if (nil == url || param == url) {
		return [NSString string];
	}
	NSInteger idx = [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location;
	if (idx != NSNotFound) {
		
		NSString *paramList = [url substringFromIndex:idx+1];
		NSArray *arr = [paramList componentsSeparatedByString:@"&"];
		NSInteger minlen = [param length] + 1;
		
		for (NSString *arrStr in arr) {
			if ([arrStr length] > minlen && ([param caseInsensitiveCompare:[arrStr substringToIndex:minlen-1]] == NSOrderedSame)) {
				NSInteger index = [arrStr rangeOfString:@"=" options:NSCaseInsensitiveSearch].location;
				NSString *first = [arrStr substringToIndex:index];
				if ([param caseInsensitiveCompare:first] == NSOrderedSame) {
					return [arrStr substringFromIndex:index+1];
				}
			}
		}
	}
	return [NSString string];
}


static NSString *const kTYQuerySeparator      = @"&";
static NSString *const kTYQueryDivider        = @"=";
static NSString *const kTYQueryBegin          = @"?";

- (NSDictionary*)ky_urlStringQueryDictionary {
	NSMutableDictionary *mute = @{}.mutableCopy;
	for (NSString *query in [self componentsSeparatedByString:kTYQuerySeparator]) {
		NSArray *components = [query componentsSeparatedByString:kTYQueryDivider];
		if (components.count == 0) {
			continue;
		}
		NSString *key = [components[0] stringByRemovingPercentEncoding];
		id value = nil;
		if (components.count == 1) {
			// key with no value
			value = [NSNull null];
		}
		if (components.count == 2) {
			value = [components[1] stringByRemovingPercentEncoding];
			// cover case where there is a separator, but no actual value
			value = [value length] ? value : [NSNull null];
		}
		if (components.count > 2) {
			// invalid - ignore this pair. is this best, though?
			continue;
		}
		mute[key] = value ?: [NSNull null];
	}
	return mute.count ? mute.copy : nil;
}

- (NSString *)ky_urlStringByRemovingQuery {
	NSArray *queryComponents = [self componentsSeparatedByString:kTYQueryBegin];
	if (queryComponents.count) {
		return queryComponents.firstObject;
	}
	return self;
}


#pragma mark - 工具（Utilities）

+ (NSString *)ky_stringWithUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return (__bridge_transfer NSString *)string;
}

+ (NSString *)ky_notNilString:(id)value {

	if (!value || value == [NSNull null]) {
		return [NSString string];
	}
	if ([value isKindOfClass:[NSNumber class]]) {
		return [value stringValue];
	}
	if ([value isKindOfClass:[NSString class]]) {
		return [value copy];
	}

	return [NSString string];
}

+ (NSString *)ky_stringWithUTF32Char:(UTF32Char)char32 {
	char32 = NSSwapHostIntToLittle(char32);
	return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)ky_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
	return [[NSString alloc] initWithBytes:(const void *)char32
									length:length * 4
								  encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)ky_enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
	NSString *str = self;
	if (range.location != 0 || range.length != self.length) {
		str = [self substringWithRange:range];
	}
	NSUInteger len = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
	UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
	if (len == 0 || char32 == NULL) return;
	
	NSUInteger location = 0;
	BOOL stop = NO;
	NSRange subRange;
	UTF32Char oneChar;
	
	for (NSUInteger i = 0; i < len; i++) {
		oneChar = char32[i];
		subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
		block(oneChar, subRange, &stop);
		if (stop) return;
		location += subRange.length;
	}
}


- (NSString *)ky_stringByTrim {
	NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	return [self stringByTrimmingCharactersInSet:set];
}


- (NSString *)ky_stringByAppendingNameScale:(CGFloat)scale {
	if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
	return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)ky_stringByAppendingPathScale:(CGFloat)scale {
	if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
	NSString *ext = self.pathExtension;
	NSRange extRange = NSMakeRange(self.length - ext.length, 0);
	if (ext.length > 0) extRange.location -= 1;
	NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
	return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

- (CGFloat)ky_pathScale {
	if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
	NSString *name = self.stringByDeletingPathExtension;
	__block CGFloat scale = 1;
	[name ky_enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
		scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
	}];
	return scale;
}

- (BOOL)ky_isNotBlank {
	NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![blank characterIsMember:c]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)ky_empty {
	return ([self length] > 0) ? NO : YES;
}

- (BOOL)ky_notEmpty {
	return ([self length] > 0) ? YES : NO;
}

+ (BOOL)ky_isEmpty:(NSString *)string {
	
    if ([string isKindOfClass:[NSString class]] == NO &&
        [[string class] isSubclassOfClass:[NSString class]] == NO) {
        return YES;
    }
    
	if (nil == string ||
        [string ky_empty]) {
		return YES;
	}
	return NO;
}

+ (BOOL)ky_isNotEmpty:(NSString *)string {
	
	return ![NSString ky_isEmpty:string];
}

- (BOOL)ky_containsString:(NSString *)string {
	return [self ky_containsString:string caseInsens:YES];
}

- (BOOL)ky_containsString:(NSString *)string caseInsens:(BOOL)caseInsens {

	if (nil == string || NO == [string isKindOfClass:[NSString class]]) {
		return NO;
	}
	NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : 0;
	return [self rangeOfString:string options:option].location != NSNotFound;
}

- (BOOL)ky_containsCharacterSet:(NSCharacterSet *)set {
	if (set == nil) return NO;
	return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSNumber *)ky_numberValue {
	return [NSNumber ky_numberWithString:self];
}

- (NSData *)ky_dataValue {
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)ky_urlValue {
	return [NSURL URLWithString:self];
}

- (NSRange)ky_rangeOfAll {
	return NSMakeRange(0, self.length);
}

+ (NSString *)ky_stringNamed:(NSString *)name {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
	NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	if (!str) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
		str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	}
	return str;
}

- (CGFloat)ky_unicodeLength {
    CGFloat asciiLength = 0;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar uc = [self characterAtIndex: i];
        if(isblank(uc)){//判断字符串为空或为空格
            asciiLength += 0.5;
        }else if(isascii(uc)){
            asciiLength += 0.5;
        }else{
            asciiLength += 1;
        }
    }
    return asciiLength;
}

- (CGFloat)ky_unicodeLength:(NSUInteger)maxLength out_rangeLength:(NSUInteger *)out_rangeLength {
    
    CGFloat l=0,a=0,b=0;
    CGFloat wLen=0;
    unichar c;
    for(int i=0; i< [self length]; i++){
        c = [self characterAtIndex:i];//按顺序取出单个字符
        if(isblank(c)){//判断字符串为空或为空格
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
        wLen = l+(CGFloat)((CGFloat)(a+b)/2.0);
        if (wLen>= (maxLength/2-0.5) &&wLen<(maxLength/2+0.5)) { //设定这个范围是因为，当输入了当输入9英文，即4.5，后面还能输1字母，但不能输1中文
            *out_rangeLength = l+a+b;//_subLen是要截取字符串的位置
        }
    }
    if(a==0 && l==0) {
        *out_rangeLength = 0;
        return 0;//只有isblank
    }
    else{
        return wLen;//长度，中文占1，英文等能转ascii的占0.5
    }
}

@end
