//
//  AppDelegate.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // This is boilerplate code that you’ll find in just about any app that uses nibs.
    
  // creates the UIWindow object. Every app needs at least one window and that window needs to have a rootViewController.
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // creat the search view controller here by loading it from the nib with the same name.
  self.searchViewController =
      [[SearchViewController alloc] initWithNibName:@"SearchViewController"
                                             bundle:nil];
    // set the root view controller as the root controller
  self.window.rootViewController = self.searchViewController;
  //make the window and everything in it visible.
  [self.window makeKeyAndVisible];
  return YES;
}

@end
