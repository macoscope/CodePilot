//
//  MCLog.h
//  Macoscope Commons Library
//
//  Created by Daniel on 08-11-03.
//  Copyright 2008 Macosope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCLog : NSObject
+ (void)file:(char *)sourceFile function:(char *)functionName lineNumber:(int)lineNumber format:(NSString *)format, ...;
+ (NSString *)messageWithFile:(char *)sourceFile function:(char *)functionName lineNumber:(int)lineNumber format:(NSString *)format, ...;
+ (void)prefix:(NSString *)prefixString format:(NSString *)format, ...;
@end


#define LOG(s,...) [MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LOGCALL [MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:@"%s", _cmd]

#define LOG_if (condition, s, ...) 												\
do {																				\
	if ( (condition) ) {															\
		[MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]; \
	}																			\
} while (0)

#define WARN_if (condition, s, ...) 												\
do {																				\
	if ( (condition) ) {															\
		[MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]; \
	}																			\
} while (0)

#define WARN(s,...) [MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define ERROR(s,...) [MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]

// cos a'la log ale zwracajace message zamiast wrzucac go do logow - przydatne jako domyslny komunikat w assercjach
#define LOGMSG(s,...) [MCLog messageWithFile:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define FAILMSG [MCLog messageWithFile:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:@"Assertion failed."]



// Based on http://www.dribin.org/dave/blog/archives/2008/09/22/convert_to_nsstring/
NSString * MCToStringFromTypeAndValue(const char * typeCode, void * value);
#define MCNSStringWithFormat(FORMAT, ARGS... )  [NSString stringWithFormat: (FORMAT), ARGS]
// mnemo - [F]or[M]atted [S]tring
#define _fms(FORMAT, ARGS... )  [NSString stringWithFormat: (FORMAT), ARGS]

#define _2NS(_X_) ({__typeof__(_X_) _Y_ = (_X_);  MCToStringFromTypeAndValue(@encode(__typeof__(_X_)), &_Y_);})
#define LOGVAR(_X_)	 {__typeof__(_X_) _Y_ = (_X_); [MCLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:@"?%s = `%@'", # _X_, MCToStringFromTypeAndValue(@encode(__typeof__(_X_)), &_Y_)];}
