//
//  CPResult.m
//  CodePilot
//
//  Created by Karol Kozub on 14.08.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "CPResult.h"

@implementation CPResult
- (NSString *)name
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString *)sourceFile
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (double)scoreOffset
{
  [self doesNotRecognizeSelector:_cmd];
  return 0;
}

- (BOOL)isSearchable
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (BOOL)isOpenable
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (BOOL)isImplementation
{
  NSArray *extensions = @[@".m", @".c", @".cpp", @".cc", @".mm"];
  for (NSString *extension in extensions) {
    if ([[self sourceFile] hasSuffix:extension]) {
      return YES;
    }
  }
  
  return NO;
}
@end
