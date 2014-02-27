//
//  AppDelegate.m
//  Alpha
//
//  Created by Josh Bassett on 24/02/2014.
//  Copyright (c) 2014 Gamedogs. All rights reserved.
//

#import <RXCollections/RXCollection.h>

#import "AppDelegate.h"

static NSString const *targetWindowName = @"iOS Simulator";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Ensure the window is always on top.
  _window.level = NSFloatingWindowLevel;

  // Change the window alpha value so that it blends with the target window.
  _window.alphaValue = 0.5f;

  // Make the window background to transparent.
  _window.backgroundColor = [NSColor clearColor];

  // Ensure mouse events are passed through to the target window.
  _window.ignoresMouseEvents = YES;

  [self bringTargetWindowToFront];

  [NSTimer scheduledTimerWithTimeInterval:0.1f
                                   target:self
                                 selector:@selector(trackTargetWindowFrame)
                                 userInfo:nil
                                  repeats:YES];
}

#pragma mark - Handlers

- (void)openDocument:(id)sender {
  _window.level = NSNormalWindowLevel;

  NSOpenPanel *openPanel = [NSOpenPanel openPanel];

  NSArray *imageTypes = [NSImage imageTypes];
  [openPanel setAllowedFileTypes:imageTypes];

  [openPanel beginWithCompletionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
      [self openImageWithContentsOfURL:openPanel.URL];
    }

    _window.level = NSFloatingWindowLevel;
  }];
}

- (void)performClose:(id)sender {
  _imageView.image = nil;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  return [self openImageWithContentsOfURL:[NSURL fileURLWithPath:filename]];
}

#pragma mark - Private methods

- (NSDictionary *)targetWindowInfo {
	NSArray *windows = (__bridge_transfer NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);

  NSDictionary *entry = [windows rx_detectWithBlock:^BOOL(NSDictionary *entry) {
		NSString *windowName = [entry objectForKey:(id)kCGWindowName];
    return [windowName hasPrefix:(id)targetWindowName];
  }];

  return entry;
}

- (CGRect)convertScreenToWindow:(CGRect)aRect {
  CGRect frame = CGRectInset(aRect, 0, 0);

  // Convert from screen space to view space.
  frame.origin.y = [NSScreen mainScreen].frame.size.height - aRect.origin.y - aRect.size.height;

  // XXX: Ignore title bar. We don't always need to do this.
  frame.size.height -= 22;

  return frame;
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

  [_window setFrame:[self convertScreenToWindow:bounds] display:YES];
}

- (BOOL)openImageWithContentsOfURL:(NSURL *)URL {
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:URL];

  if (image) {
    _imageView.image = image;
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:URL];
    return YES;
  } else {
    return NO;
  }
}

@end
