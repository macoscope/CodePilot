//
//  NSAttributedString+Hyperlink.h
//  Quark
//
//  Created by Daniel on 09-12-17.
//  Copyright 2009 Macosope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Hyperlink)
+ (NSAttributedString *)hyperlinkFromString:(NSString *)inString withURL:(NSURL *)aURL;
@end
