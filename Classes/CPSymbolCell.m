//
//  CPSymbolCell.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSymbolCell.h"
#import "CPCodePilotConfig.h"
#import "CPSymbol.h"
#import "NSColor+ColorArithmetic.h"

@implementation CPSymbolCell
@dynamic cpSymbol;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  [super drawWithFrame:cellFrame inView:controlView];
  
	if (nil == self.cpSymbol || IsEmpty([self.cpSymbol name]) ||
      (IsEmpty([self.cpSymbol sourceFile]) && [self.cpSymbol isKindOfClass:[CPSymbol class]])) {
		return;
	}
  
	[self drawSymbolNameWithFrame:cellFrame];
  
	if (self.extendedDisplay) {
		[self drawSourceFileNameWithFrame:cellFrame];
	}
  
	[self drawIconImage:[self.cpSymbol icon] withFrame:cellFrame];
}

- (void)drawSymbolNameWithFrame:(NSRect)cellFrame
{
	NSMutableDictionary *symbolNameStringAttributes = [[self defaultStringAttributes] mutableCopy];
  NSColor *symbolNameForegroundColor = [self isHighlighted] ? [self symbolNameForegroundColorWithHighlight] : [self symbolNameForegroundColorWithoutHighlight];
  
	[symbolNameStringAttributes setObject:[NSFont fontWithName:SYMBOL_SELECTION_CELL_FONT_NAME
																												size:SYMBOL_SELECTION_CELL_FONT_SIZE]
																 forKey:NSFontAttributeName];
  
	[symbolNameStringAttributes setObject:symbolNameForegroundColor
                                 forKey:NSForegroundColorAttributeName];
  
	NSMutableAttributedString *symbolNameAttributedString = [[self queryHitAttributedStringWithString:[self.cpSymbol name]] mutableCopy];
	[symbolNameAttributedString addAttributes:symbolNameStringAttributes range:NSMakeRange(0, [symbolNameAttributedString length])];
  
  CGFloat iconWidth = self.extendedDisplay ? RESULT_CELL_SYMBOL_EXTENDED_ICON_WIDTH : RESULT_CELL_SYMBOL_ICON_WIDTH;
  CGFloat symbolNameOffsetY = self.extendedDisplay ? 4 : 3;
  
  [symbolNameAttributedString drawInRect:NSMakeRect(cellFrame.origin.x + iconWidth, cellFrame.origin.y + symbolNameOffsetY, cellFrame.size.width - iconWidth, cellFrame.size.height)];
}

- (void)drawSourceFileNameWithFrame:(NSRect)cellFrame
{
	NSString *sourceFilename = [self.cpSymbol sourceFile];
  
	if (sourceFilename) {
		sourceFilename = [[sourceFilename componentsSeparatedByString:@"/"] lastObject];
    
		NSMutableDictionary *symbolFileNameStringAttributes = [[self defaultStringAttributes] mutableCopy];
    
		[symbolFileNameStringAttributes setObject:[NSFont fontWithName:SYMBOL_SELECTION_CELL_EXTENDED_INFO_FONT_NAME
																															size:SYMBOL_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE]
																			 forKey:NSFontAttributeName];
    
		if ([self isHighlighted]) {
      [symbolFileNameStringAttributes setObject:SYMBOL_SELECTION_CELL_HIGHLIGHTED_EXTENDED_INFO_COLOR
                                         forKey:NSForegroundColorAttributeName];
    } else {
      [symbolFileNameStringAttributes setObject:SYMBOL_SELECTION_CELL_EXTENDED_INFO_COLOR
                                         forKey:NSForegroundColorAttributeName];
    }
    
		NSAttributedString *symbolFileNameString = [[NSAttributedString alloc] initWithString:sourceFilename
																																							 attributes:symbolFileNameStringAttributes];
    
    CGFloat iconMargin;
    if (self.extendedDisplay) {
      iconMargin = RESULT_CELL_SYMBOL_EXTENDED_ICON_WIDTH;
    } else {
      iconMargin = RESULT_CELL_SYMBOL_ICON_WIDTH;
    }
    
    const CGFloat CellFrameOffsetX = iconMargin;
    const CGFloat CellFrameOffsetY = SYMBOL_SELECTION_CELL_FONT_SIZE + 9;
    
		[symbolFileNameString drawInRect:NSMakeRect(cellFrame.origin.x + CellFrameOffsetX,
																								cellFrame.origin.y + CellFrameOffsetY,
																								cellFrame.size.width - CellFrameOffsetX,
																								cellFrame.size.height - CellFrameOffsetY)];
	}
}

- (CPSymbol *)cpSymbol
{
  return (CPSymbol *)self.objectValue;
}

- (NSUInteger)requiredHeight
{
	if (self.extendedDisplay) {
		return SYMBOL_SELECTION_CELL_EXTENDED_HEIGHT;
	} else {
		return SYMBOL_SELECTION_CELL_HEIGHT;
	}
}

- (NSColor *)symbolNameForegroundColorWithoutHighlight
{
  NSColor *standardColor = [self symbolNameForegroundColor];
  
  return [standardColor colorWithAlphaComponent:[standardColor alphaComponent] * 0.7];
}

- (NSColor *)symbolNameForegroundColorWithHighlight
{
  return [self symbolNameForegroundColor];
}

- (NSColor *)symbolNameForegroundColor
{
  const static CGPoint ForegroundColorPositionOnStandardBitmap = {2, 2};
  const static CGPoint ForegroundColorPositionOnRetinaBitmap = {4, 4};
  
	if ([self.cpSymbol icon]) {
    NSData *tiffRepData = [[self.cpSymbol icon] TIFFRepresentation];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithData:tiffRepData];
    if (bitmapRep) {
      BOOL iconUsesRetinaResolution = [bitmapRep pixelsWide] > [self.cpSymbol icon].size.width;
      CGPoint position = iconUsesRetinaResolution ? ForegroundColorPositionOnRetinaBitmap : ForegroundColorPositionOnStandardBitmap;
      NSColor *colorFromBitmap = [bitmapRep colorAtX:position.x y:position.y];
      NSColor *foregroundColor;
      
      // now let's avoid low alpha and lighten up the dark colors
      if ([colorFromBitmap isDark]) {
        foregroundColor = [colorFromBitmap colorByMutliplyingComponentsBy:2];
        
      } else {
        foregroundColor = colorFromBitmap;
      }
      
      return [foregroundColor colorWithAlphaComponent:1];
    }
	}
  
	return SYMBOL_OTHER_NAME_COLOR;
}

- (NSColor *)symbolCategoryNameForegroundColor
{
	// now let's avoid low alpha and lighten up the dark colors
	return [[[self symbolNameForegroundColor] colorByMutliplyingComponentsBy:0.8] colorWithAlphaComponent:1];
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
  return NSZeroRect;
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
{
  return;
}
@end