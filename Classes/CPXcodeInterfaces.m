//
//  CPXcodeInterfaces.m
//  CodePilot
//
//  Created by Karol Kozub on 22.07.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "CPXcodeInterfaces.h"

@implementation IDEWorkspaceWindow (MissingMethods)
+ (IDEWorkspaceWindow *)mc_lastActiveWorkspaceWindow
{
  if ([self respondsToSelector:@selector(lastActiveWorkspaceWindow)]) {
    return [self performSelector:@selector(lastActiveWorkspaceWindow)];
  }
  
  if ([self respondsToSelector:@selector(lastActiveWorkspaceWindowController)]) {
    IDEWorkspaceWindowController *workspaceWindowController = [self performSelector:@selector(lastActiveWorkspaceWindowController)];
    
    return (IDEWorkspaceWindow *)[workspaceWindowController window];
  }
  
  return nil;
}
@end
