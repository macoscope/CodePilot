//
//  CPSymbolCache.h
//  CodePilot
//
//  Created by karol on 5/11/12.
//  Copyright (c) 2012 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CPSymbol, IDEIndexSymbol;

@interface CPSymbolCache : NSObject
+ (CPSymbolCache *)sharedInstance;

- (CPSymbol *)symbolForIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol relatedFilePath:(NSString *)relatedFilePath;
@end
