//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

// Why do we make the IBOutlets weak?
// Recall that as soon as an object no longer has any strong pointers, it goes away (it is deallocated) and all the weak pointers become nil. Per Apple’s recommendation you’ve been making your outlets weak pointers. You may be wondering, if the pointers to these view objects are weak, then won’t the objects get deallocated too soon?
// Answer: Views are always part of a view hierarchy and they will always have an owner with a strong pointer: their superview. In this screen, the SearchViewController’s main view object will hold a reference to both the search bar and the table view. This is done inside UIKit and you don’t have to worry about it. As long as the view controller exists, so will these two outlets.
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar. Now the first row will always be visible, and when you scroll the table view the cells still go under the search bar. Nice.
    // Before putting this, the top cells in the table view were cut off.
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
