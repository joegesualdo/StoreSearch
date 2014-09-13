//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/12/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Search;

@interface LandscapeViewController : UIViewController

// app needs to give the search results to LandscapeViewController so it can use them for its calculations.
// set this property in SearchViewController upon rotation to landscape. 
@property (nonatomic, strong) Search *search;

@end
