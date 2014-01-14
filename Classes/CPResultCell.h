//
//  ResultCell.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/2/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CPResultCell : NSTextFieldCell
@property (nonatomic, assign) BOOL extendedDisplay;
@property (nonatomic, strong) NSString *query;

- (NSParagraphStyle *)defaultParagraphStyle;
- (NSDictionary *)characterHitExtraAttributes;
- (NSDictionary *)defaultStringAttributes;
- (NSAttributedString *)queryHitAttributedStringWithString:(NSString *)subjectString;
- (void)drawIconImage:(NSImage *)icon withFrame:(NSRect)cellFrame;
- (void)drawWithBackgroundImageNamed:(NSString *)backgroundImageName withFrame:(NSRect)cellFrame;
@end