//
//  CPPreferencesView.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/10/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CPPreferencesView : NSView
@property (nonatomic, strong) NSButton *autocopyingSelectionCheckbox;
@property (nonatomic, strong) NSButton *externalEditorCheckbox;

- (id)initWithPreferredFrame;

+ (CGFloat)preferredWidth;
+ (CGFloat)preferredHeight;
@end
