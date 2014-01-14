//
//  SearchFieldTextView.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPSearchFieldTextView : NSTextView
@property (nonatomic, assign) BOOL someKeyIsDown;
- (void)pasteString:(NSString *)str;
@end
