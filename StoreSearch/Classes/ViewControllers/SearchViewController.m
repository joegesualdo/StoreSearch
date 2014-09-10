//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

// This defines a symbolic name, SearchResultCellIdentifier, with the value @"SearchResultCell". Should you want to change this value, then you only have to do it here and any code that uses SearchResultCellIdentifier will be automatically updated.
// There is another reason for using a symbolic name rather than the actual value: it gives extra meaning. Just seeing the text @"SearchResultCell" says less about its intended purpose than the word SearchResultCellIdentifier.
static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";

// hook up the data source and delegate protocols yourself.
@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

// Why do we make the IBOutlets weak?
// Recall that as soon as an object no longer has any strong pointers, it goes away (it is deallocated) and all the weak pointers become nil. Per Apple’s recommendation you’ve been making your outlets weak pointers. You may be wondering, if the pointers to these view objects are weak, then won’t the objects get deallocated too soon?
// Answer: Views are always part of a view hierarchy and they will always have an owner with a strong pointer: their superview. In this screen, the SearchViewController’s main view object will hold a reference to both the search bar and the table view. This is done inside UIKit and you don’t have to worry about it. As long as the view controller exists, so will these two outlets.
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end

@implementation SearchViewController
{
    // instance variables
    NSMutableArray *_searchResults;
}

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
    
    // The UINib class is used to load nibs. Here you tell it to load the nib you just created (note that you don’t specify the .xib file extension). Then you ask the table view to register this nib for the reuse identifier “SearchResultCell”.
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    // adjust the row height
    self.tableView.rowHeight = 80;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if (_searchResults == nil) {
        return 0;
    // If there are no results this now returns 1, for the row with the text “(Nothing Found)”.
    } else if ([_searchResults count] == 0) {
        return 1;
    } else {
        return [_searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // only make a SearchResultCell if there are actually any results. If the array is empty, you’ll simply dequeue the cell for the NothingFoundCellIdentifier and return it
  if ([_searchResults count] == 0) {
    return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                        forIndexPath:indexPath];
  } else {
    SearchResultCell *cell = (SearchResultCell *)
        [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier
                                        forIndexPath:indexPath];
    SearchResult *searchResult = _searchResults[indexPath.row];
    cell.nameLabel.text = searchResult.name;
    cell.artistNameLabel.text = searchResult.artistName;
    return cell;
  }
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  simply deselect the row with an animation,
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // makes sure that you can only select rows with actual search results.
  if ([_searchResults count] == 0) {
    return nil;
  } else {
    return indexPath;
  }
}

#pragma mark - UISearchBarDelegate
// is invoked when the user taps the Search button on the keyboard.

// this delegate method will will put some fake data into this array and then use it to fill up the table.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  // tells the UISearchBar that it should no longer listen to keyboard input and as a result, the keyboard will hide itself until you tap inside the search bar again.
   [searchBar resignFirstResponder];
  //allocate a new NSMutableArray object and put it into the _searchResults instance variable. This is done each time the user performs a search.
  _searchResults = [NSMutableArray arrayWithCapacity:10];
  // You have added an if-statement that compares the search text to @"justin bieber". Only if there is no match will this create the SearchResult objects and add them to the array.
  if (![searchBar.text isEqualToString:@"justin bieber"]) {
      // You add a string with some text into the array. Just for the fun of it, that is repeated 3 times so your data model will have three rows in it.
      for (int i = 0; i < 3; i++) {
          // creates the new SearchResult object and simply puts some fake text into its name and artistName properties.
          SearchResult *searchResult = [[SearchResult alloc] init];
          searchResult.name = [NSString stringWithFormat: @"Fake Result %d for", i];
          searchResult.artistName = searchBar.text;
          [_searchResults addObject:searchResult];
      }
  }
  // The last statement in the method reloads the table view to make the new rows visible, which means you have to adapt the table view data source methods to read from this array as well.
  [self.tableView reloadData];
}

// The search bar has an ugly white gap above it. This removes it
// This is part of the SearchBarDelegate protocol.
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
  return UIBarPositionTopAttached;
}

@end
