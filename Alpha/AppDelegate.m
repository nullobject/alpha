//
//  AppDelegate.m
//  Alpha
//
//  Created by Josh Bassett on 24/02/2014.
//  Copyright (c) 2014 Gamedogs. All rights reserved.
//

#import <RXCollections/RXCollection.h>

#import "AppDelegate.h"

static NSString const *name = @"iOS Simulator";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Ensure the window is always on top.
  _window.level = NSFloatingWindowLevel;

  _window.alphaValue = 0.5f;
//  _window.backgroundColor = [NSColor clearColor];
  _window.backgroundColor = [NSColor greenColor];

  // Pass-through mouse events.
  _window.ignoresMouseEvents = YES;

  [self bringTargetWindowToFront];

  [NSTimer scheduledTimerWithTimeInterval:0.1f
                                   target:self
                                 selector:@selector(trackTargetWindowFrame)
                                 userInfo:nil
                                  repeats:YES];
}

- (NSDictionary *)targetWindowInfo {
	NSArray *windows = (__bridge_transfer NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);

  NSDictionary *entry = [windows rx_detectWithBlock:^BOOL(NSDictionary *entry) {
		NSString *windowName = [entry objectForKey:(id)kCGWindowName];
    return [windowName hasPrefix:(id)name];
  }];

  return entry;
}

- (CGRect)convertScreenToView:(CGRect)rect {
  CGRect newRect = CGRectInset(rect, 0, 0);

  // Convert from screen space to view space.
  newRect.origin.y = [NSScreen mainScreen].frame.size.height - newRect.origin.y - newRect.size.height;

  // XXX: Ignore title bar. We don't always need to do this.
  newRect.size.height -= 22;

  return newRect;
}

- (void)bringTargetWindowToFront {
  NSDictionary *entry = [self targetWindowInfo];
  pid_t pid = (pid_t)[[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
  NSRunningApplication *runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
  [runningApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void)trackTargetWindowFrame {
  NSDictionary *entry = [self targetWindowInfo];

  CGRect bounds;
  CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);

  [_window setFrame:[self convertScreenToView:bounds] display:YES];
}

@end
