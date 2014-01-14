//
//  MCCommons.h
//  Macoscope Commons Library
//
//  Created by Daniel on 08-11-03.
//  Copyright 2008 Macosope. All rights reserved.
//

#import "MCLog.h"
#import "NSString+MiscExtensions.h"


#ifndef NSNotFoundRange
#  define NSNotFoundRange       ((NSRange) {.location = NSNotFound, .length = 0UL})
#endif

static inline BOOL IsEmpty(id thing) {
  return thing == nil
  || ([NSNull null]==thing)
  || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
  || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}
