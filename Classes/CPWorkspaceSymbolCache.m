//
//  CPWorkspaceSymbolCache.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 5/20/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "CPWorkspaceSymbolCache.h"

// holds symbol cache for particular workspace
@implementation CPWorkspaceSymbolCache

+ (CPWorkspaceSymbolCache *)symbolCacheWithSymbols:(NSArray *)symbols forWorkspace:(IDEWorkspace *)workspace
{
  CPWorkspaceSymbolCache *newCache = [[CPWorkspaceSymbolCache alloc] init];
  newCache.workspace = workspace;
  newCache.symbols = symbols;
  
  return newCache;
}
@end
