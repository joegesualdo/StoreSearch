//
//  DetailViewController.h
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/11/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResult;

@interface DetailViewController : UIViewController

// this property should be in the public header file because you need an other object to set it (namely the SearchViewController).
@property (nonatomic, strong) SearchResult *searchResult;

- (void)presentInParentViewController: (UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

@end
