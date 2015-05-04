//
//  NSWorkspace+OpenFileOnLine.m
//  CodePilot
//
//  Created by Fjölnir Ásgeirsson on 2/2/14.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//

#import "NSWorkspace+OpenFileOnLine.h"

NSString *kSublimeText2Identifier = @"com.sublimetext.2";
NSString *kSublimeText3Identifier = @"com.sublimetext.3";
NSString *kMacVimIdentifier       = @"org.vim.MacVim";
NSString *kTextmateIdentifier     = @"com.macromates.textmate";
NSString *kTextmate2Identifier    = @"com.macromates.textmate.preview";
NSString *kBBEditIdentifier       = @"com.barebones.bbedit";


@implementation NSWorkspace (OpenFileOnLine)

+ (NSString *)cp_schemeForEditor:(NSString *)editor
{
  if ([editor isEqualToString:kSublimeText2Identifier] ||
      [editor isEqualToString:kSublimeText3Identifier]) {
    return @"subl";
  }
  if ([editor isEqualToString:kMacVimIdentifier]) {
    return @"mvim";
  }
  if ([editor isEqualToString:kTextmateIdentifier]) {
    return @"txmt";
  }
  if ([editor isEqualToString:kBBEditIdentifier]) {
    return @"txmt";
  }
  else {
    return nil;
  }
}

- (void)cp_openURL:(NSURL *)url onLine:(NSUInteger)line
{
  NSURL *editorURL = [self URLForApplicationToOpenURL:url];
  NSString *editorIdentifier = [[NSBundle bundleWithURL:editorURL] bundleIdentifier];
  NSString *scheme = [[self class] cp_schemeForEditor:editorIdentifier];
  
  if (scheme) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://open?url=%@&line=%lu",
                                scheme,
                                [[url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                (unsigned long)line]];
  }
  [self openURL:url];
}

@end
