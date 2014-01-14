//
//  ResultCell.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/2/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPResultCell.h"
#import "CPCodePilotConfig.h"

@implementation CPResultCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  NSInteger rowIndex = [(NSTableView *)controlView rowAtPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y)];
  
  NSString *backgroundImageFileName;
  
  if ([self isHighlighted]) {
    backgroundImageFileName = @"ResultSelection";
  } else {
    if (rowIndex % 2) {
      backgroundImageFileName = @"DarkCell";
    } else {
      backgroundImageFileName = @"LightCell";
    }
  }
  
  [self drawWithBackgroundImageNamed:backgroundImageFileName withFrame:cellFrame];
}

- (void)drawWithBackgroundImageNamed:(NSString *)backgroundImageName withFrame:(NSRect)cellFrame
{
  NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:backgroundImageName
                                                                         ofType:@"png"];
  
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
  
  NSImageRep *imageRep = [[image representations] objectAtIndex:0];
  
  [imageRep drawInRect:cellFrame
              fromRect:NSMakeRect(0, 0, imageRep.size.width, imageRep.size.height)
             operation:NSCompositeSourceOver
              fraction:1.0
        respectFlipped:YES
                 hints:nil];
}

- (NSParagraphStyle *)defaultParagraphStyle
{
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	return paragraphStyle;
}

// what extra attributes does a character need when it's hit with a query
- (NSDictionary *)characterHitExtraAttributes
{
	return [[NSDictionary alloc] initWithObjectsAndKeys:
					[NSNumber numberWithInt:NSUnderlineStyleThick], NSUnderlineStyleAttributeName, nil];
}

// sourceString with hit attributes added in all the right places
- (NSAttributedString *)queryHitAttributedStringWithString:(NSString *)subjectString
{
	NSMutableAttributedString *attributedSubjectString = [[NSMutableAttributedString alloc] initWithString:subjectString];
  
	if (!IsEmpty(self.query)) {
		NSArray *hitsArray = [subjectString hitsForString:self.query];
		for (NSNumber *characterIndexOnHit in hitsArray) {
			[attributedSubjectString addAttributes:[self characterHitExtraAttributes]
																			 range:NSMakeRange([characterIndexOnHit unsignedIntValue], 1)];
		}
	}
  
	return attributedSubjectString;
}

- (NSDictionary *)defaultStringAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys: [NSColor clearColor], NSBackgroundColorAttributeName,
          [self defaultParagraphStyle], NSParagraphStyleAttributeName, nil];
}

- (void)drawIconImage:(NSImage *)icon withFrame:(NSRect)cellFrame
{
  if (icon) {
    NSRect availableRect; // rect (part of cellFrame), available for drawing
	  NSRect srcRect, dstRect; // dstRect is the actual rect where image from srcrect lands
    
    srcRect.origin = NSZeroPoint;
    srcRect.size = [icon size];
    
    availableRect = NSMakeRect(cellFrame.origin.x + RESULT_CELL_ICON_LEFT_MARGIN,
                               cellFrame.origin.y + 4,
                               RESULT_CELL_FILE_ICON_WIDTH,
                               cellFrame.size.height - 8);
    
    // TODO/FIXME: adjust origins to make it look good if aspect ratio is out of whack
    dstRect.origin.x = availableRect.origin.x;
    dstRect.origin.y = availableRect.origin.y;
    
    dstRect.size.height = availableRect.size.height;
    dstRect.size.width = srcRect.size.width / (srcRect.size.height / availableRect.size.height);
    
    [icon drawInRect:dstRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
  }
}
@end