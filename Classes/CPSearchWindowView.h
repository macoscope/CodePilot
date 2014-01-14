//
//  CPSearchWindowView.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPHUDViewWithRoundCorners.h"
#import "CPCodePilotConfig.h"

#define WINDOW_INFO_LABEL_TOPMARGIN			6.0f
#define WINDOW_INFO_LABEL_HEIGHT            21.0f
#define WINDOW_SEARCHFIELD_TOPMARGIN        7.0f
#define WINDOW_SEARCHFIELD_HEIGHT           28.0f
#define WINDOW_SEARCHFIELD_LEFT_MARGIN      27.0f
#define WINDOW_UPPER_STATUS_LABEL_TOPMARGIN 25.0f
#define WINDOW_UPPER_STATUS_LABEL_HEIGHT    19.0f
#define WINDOW_TABLEVIEW_TOPMARGIN			4.0f
#define WINDOW_LOWER_STATUS_LABEL_TOPMARGIN 8.0f
#define WINDOW_LOWER_STATUS_LABEL_HEIGHT    19.0f
#define WINDOW_CONTENT_BOTTOMMARGIN			6.0f


@class CPResultTableView, CPSearchField, CPStatusLabel;

@interface CPSearchWindowView : CPHUDViewWithRoundCorners
@property (nonatomic, strong) CPSearchField *searchField;
@property (nonatomic, strong) CPStatusLabel *infoStatusLabel;
@property (nonatomic, strong) CPStatusLabel *upperStatusLabel;
@property (nonatomic, strong) CPStatusLabel *lowerStatusLabel;
@property (nonatomic, strong) CPResultTableView *resultTableView;
@property (nonatomic, strong) NSScrollView *resultTableScrollView;
@property (nonatomic, strong) NSControl *indexingProgressIndicator;
@property (nonatomic, assign) NSUInteger currentMainContentViewHeight;
@property (nonatomic, strong) NSImageRep *headerImageRepresentation;
@property (nonatomic, strong) NSImageRep *headerWithInfoImageRepresentation;
@property (nonatomic, strong) NSImageRep *footerImageRepresentation;
@property (nonatomic, strong) NSImageRep *infoLabelBarImageRepresentation;
@property (nonatomic, assign) BOOL documentationViewOn;

- (NSSize)windowFrameRequirements;
- (void)layoutSubviews;
- (void)setupIndexingProgressIndicator;
- (void)setupResultTableScrollViewAndResultTableView;
- (void)setupUpperStatusLabel;
- (void)setupLowerStatusLabel;
- (void)setupSearchField;
- (void)setupResultTableView;
- (void)setupInfoLabel;
- (BOOL)_infoLabelPresent;
- (NSInteger)mainContentViewHeight;
- (void)removeOrAddToSubviewsBasedOnVisibilityOfView:(NSView *)view;
- (void)alignIndexingProgressIndicator;
- (void)alignLowerStatusLabel;
- (void)alignUpperStatusLabel;
- (void)alignScrollViewFrame;
- (void)alignSearchField;
- (void)alignInfoStatusLabel;

- (void)loadUIElements;
- (void)loadFooterImageRepresentation;
- (void)loadHeaderImageRepresentation;
- (void)loadInfoLabelBarImageRepresentation;
- (void)drawHeader;
- (void)drawFooter;
- (void)drawInfoLabelBar;

@end
