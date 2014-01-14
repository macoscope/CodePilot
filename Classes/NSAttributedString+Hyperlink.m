//
//  NSAttributedString+Hyperlink.m
//  Quark
//
//  Created by Daniel on 09-12-17.
//  Copyright 2009 Macosope. All rights reserved.
//

#import "NSAttributedString+Hyperlink.h"

@implementation NSAttributedString (Hyperlink)
+ (NSAttributedString *)hyperlinkFromString:(NSString *)inString withURL:(NSURL *)aURL
{
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:inString];
  NSRange range = NSMakeRange(0, [attrString length]);
  
  [attrString beginEditing];
  [attrString addAttributes:@{NSLinkAttributeName: [aURL absoluteString],
                              NSToolTipAttributeName: [aURL absoluteString],
                              NSForegroundColorAttributeName: [NSColor blueColor],
                              NSUnderlineStyleAttributeName: @(NSSingleUnderlineStyle)}
                      range:range];
  [attrString endEditing];
  
  return attrString;
}
@end
