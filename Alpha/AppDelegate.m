//
//  AppDelegate.m
//  Alpha
//
//  Created by Josh Bassett on 24/02/2014.
//  Copyright (c) 2014 Gamedogs. All rights reserved.
//

#import <RXCollections/RXCollection.h>

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Ensure the window is always on top.
  _window.level = NSFloatingWindowLevel;

  _window.alphaValue = 0.5f;
//  _window.backgroundColor = [NSColor clearColor];
  _window.backgroundColor = [NSColor greenColor];

  // Pass-through mouse events.
  _window.ignoresMouseEvents = YES;

  [NSTimer scheduledTimerWithTimeInterval:0.25f
                                   target:self
                                 selector:@selector(updateWindowFrame)
                                 userInfo:nil
                                  repeats:YES];
}

- (void)updateWindowFrame {
	CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
  NSArray *windows = (__bridge_transfer NSArray *)windowList;

  NSDictionary *entry = [windows rx_detectWithBlock:^BOOL(NSDictionary *entry) {
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
    return [applicationName isEqualToString:@"iOS Simulator"];
  }];

  CGRect bounds;
  CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
  bounds.origin.y = [NSScreen mainScreen].frame.size.height - bounds.origin.y - bounds.size.height;
  bounds.size.height -= 22;
  [_window setFrame:bounds display:YES];
}

@end
