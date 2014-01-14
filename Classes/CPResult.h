//
//  CPResult.h
//  CodePilot
//
//  Created by Karol Kozub on 14.08.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPResult : NSObject
- (NSString *)name;
- (NSString *)sourceFile;
- (double)scoreOffset;
- (BOOL)isSearchable;
- (BOOL)isOpenable;
- (BOOL)isImplementation;
@end
