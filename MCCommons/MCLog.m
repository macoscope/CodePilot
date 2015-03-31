//
//  MCLog.m
//  Macoscope Commons Library
//
//  Created by Daniel on 08-11-03.
//  Copyright 2008 Macosope. All rights reserved.
//

#import "MCLog.h"
#import "CPCodePilotConfig.h"

@implementation MCLog
+ (void)prefix:(NSString *)prefixString format:(NSString *)format, ...
{
  @autoreleasepool {
    va_list ap;
    NSString *message;
    va_start(ap,format);
    
    message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSLog(@"%@ %@", prefixString, message);
    
  }
}

+ (void)file:(char *)sourceFile function:(char *)functionName lineNumber:(int)lineNumber format:(NSString *)format, ...
{
  @autoreleasepool {
    va_list ap;
    NSString *print, *file, *function;
    va_start(ap,format);
    
    file = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
    
    
    function = [NSString stringWithCString:functionName encoding:NSASCIIStringEncoding];
    print = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
	NSString *fileLocation = [file lastPathComponent];
    
    NSLog(@"%@:%d %@; %@", fileLocation, lineNumber, function, print);
    
  }
}
+ (NSString *)messageWithFile:(char *)sourceFile function:(char *)functionName lineNumber:(int)lineNumber format:(NSString *)format, ...
{
  @autoreleasepool {
    va_list ap;
    NSString *print, *file, *function;
    va_start(ap,format);
    file = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
    
    function = [NSString stringWithCString:functionName encoding:NSASCIIStringEncoding];
    print = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    NSString * buffer = [NSString stringWithFormat:@"%@:%d %@; %@", [file lastPathComponent], lineNumber, function, print];
    return buffer;
  }
}

NSString * MCToStringFromTypeAndValue(const char * typeCode, void * value)
{
  if (strcmp(typeCode, @encode(NSPoint)) == 0) {
    return NSStringFromPoint(*(NSPoint *)value);
    
  } else if (strcmp(typeCode, @encode(NSSize)) == 0) {
    return NSStringFromSize(*(NSSize *)value);
    
  } else if (strcmp(typeCode, @encode(NSRect)) == 0) {
    return NSStringFromRect(*(NSRect *)value);
    
  } else if (strcmp(typeCode, @encode(Class)) == 0) {
    return NSStringFromClass(*(Class *)value);
    
  } else if (strcmp(typeCode, @encode(SEL)) == 0) {
    return NSStringFromSelector(*(SEL *)value);
    
  } else if (strcmp(typeCode, @encode(NSRange)) == 0) {
    return NSStringFromRange(*(NSRange *)value);
    
  } else if (strcmp(typeCode, @encode(id)) == 0) {
    return MCNSStringWithFormat(@"%@", (__bridge id)(value));
  } else if (strcmp(typeCode, @encode(BOOL)) == 0) {
    return (*(BOOL *)value) ? @"YES" : @"NO";
  } else if (strcmp(typeCode, @encode(int)) == 0) {
    return MCNSStringWithFormat(@"%d", *(int *)value);
    
  } else if (strcmp(typeCode, @encode(NSUInteger)) == 0) {
    return MCNSStringWithFormat(@"%lu", *(NSUInteger *)value);
    
  } else if (strcmp(typeCode, @encode(unichar)) == 0) {
    return MCNSStringWithFormat(@"%d", *(unichar *)value);
    
  } else if (strcmp(typeCode, @encode(CGFloat)) == 0) {
    return MCNSStringWithFormat(@"%f", *(CGFloat *)value);
    
  } else if (strcmp(typeCode, @encode(CGPoint)) == 0) {
    return NSStringFromPoint(NSPointFromCGPoint(*(CGPoint *)value));
    
  } else if (strcmp(typeCode, @encode(CGRect)) == 0) {
    return NSStringFromRect(NSRectFromCGRect(*(CGRect *)value));
    
  } else if (strcmp(typeCode, @encode(CGSize)) == 0) {
    return NSStringFromSize(NSSizeFromCGSize(*(CGSize *)value));
  }
  
  return MCNSStringWithFormat(@"? <%s>", typeCode);
}

@end