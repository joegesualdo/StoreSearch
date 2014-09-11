//
//  AppDelegate.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"

// What is the appDelegate?
// The poor AppDelegate is often abused. People give it too many responsibilities. Really, there isn’t that much for the app delegate to do. It gets a number of callbacks about the state of the app – whether the app is about to be closed, for example – and handling those events should be its primary responsibility. The app delegate also owns the main window and the top-level view controller. Other than that, it shouldn’t do much. Some developers use the app delegate as their data model. That is just bad design. You should really have a separate class for that (or several). Others make the app delegate work as their main control hub. Wrong again! Put that stuff in your top-level view controller.

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
    
  [self customizeAppearance];
    
  //make the window and everything in it visible.
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)customizeAppearance {
    // [UIColor colorWithRed:green:blue:alpha:] method makes a new UIColor object based on the RGB and alpha color components that you specify.
    // Why do you divide by 255.0f?
    // Many painting programs let you pick RGB values going from 0 to 255 so that’s the range of color values that many programmers are accustomed to thinking in. The UIColor method, however, accepts values between 0.0 and 1.0, so you have to divide these numbers by 255.0 to scale them down to that range.
    UIColor *barTintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    [[UISearchBar appearance] setBarTintColor:barTintColor];
    self.window.tintColor = [UIColor colorWithRed:10/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
}

@end
