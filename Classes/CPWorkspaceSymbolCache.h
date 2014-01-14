//
//  CPWorkspaceSymbolCache.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 5/20/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEWorkspace;

@interface CPWorkspaceSymbolCache : NSObject
@property (nonatomic, copy) NSArray *symbols;
@property (nonatomic, strong) IDEWorkspace *workspace;

+ (CPWorkspaceSymbolCache *)symbolCacheWithSymbols:(NSArray *)symbols forWorkspace:(IDEWorkspace *)workspace;
@end
