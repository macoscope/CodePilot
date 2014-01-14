//
//  SelectedObjectCell.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/28/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPSelectedObjectCell : NSTextAttachmentCell
@property (nonatomic, assign) NSPoint cellBaselineOffset;
@property (nonatomic, assign) NSSize cellSize;
@property (nonatomic, strong) NSDictionary *stringAttributes;

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView characterIndex:(NSUInteger)charIndex;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager;
- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)aView;
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag;
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView untilMouseUp:(BOOL)flag;
- (BOOL)wantsToTrackMouse;
- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex;
@end
