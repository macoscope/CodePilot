//
//  FileSelectionCell.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/10/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPResultCell.h"

@class CPFileReference;

@interface CPFileReferenceCell : CPResultCell
@property (nonatomic, strong, readonly) CPFileReference *cpFileReference;

- (NSUInteger)requiredHeight;
- (void)drawFileNameWithFrame:(NSRect)cellFrame;
- (void)drawGroupNameWithFrame:(NSRect)cellFrame;
- (void)drawIconWithFrame:(NSRect)cellFrame;
@end
