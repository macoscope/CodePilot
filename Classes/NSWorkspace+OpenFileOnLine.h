//
//  NSWorkspace+OpenFileOnLine.h
//  CodePilot
//
//  Created by Fjölnir Ásgeirsson on 2/2/14.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSWorkspace (OpenFileOnLine)
- (void)cp_openURL:(NSURL *)url onLine:(NSUInteger)line;
@end
