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
    
    // This will make the keyboard popup with focus on the search bar when you enter the view
    [self.searchBar becomeFirstResponder];
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
        return (int)[_searchResults count];
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
    NSUInteger row = (NSUInteger) indexPath.row;
    SearchResult *searchResult = _searchResults[row];
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
    
  // we defined this urlWithSearchText below
  NSURL *url = [self urlWithSearchText:searchBar.text];
  // We defined this performStoreRequestWithURL below
  NSString *jsonString = [self performStoreRequestWithURL:url];
    
  if (jsonString == nil) {
    [self showNetworkError];
    return;
  }
    
  // this will convert the jsonString to a dictionary
  NSDictionary *dictionary = [self parseJSON:jsonString];

  if (dictionary == nil) {
    [self showNetworkError];
    return;
  }
    
  NSLog(@"Dictionary '%@'", dictionary);
    
  [self.tableView reloadData];
}

- (NSURL *)urlWithSearchText:(NSString *)searchText {
  //  A space is not a valid character in a URL. Many other characters aren’t valid either (such as the < or > signs) and therefore must be escaped. Another term for this is URL encoding. A space, for example, can be encoded as the + sign (you did that earlier when you typed the URL into the web browser) or as the character sequence %20.
  // Fortunately, NSString can do this encoding already,
    // stringbyAddingPercentEscapesUsingEcoding method escaped all the spaces by putting %20
  NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString
      stringWithFormat:@"http://itunes.apple.com/search?term=%@", escapedSearchText];
  // This creates a url object by passing it the url string
  NSURL *url = [NSURL URLWithString:urlString];
  // retuns the url obect
  return url;
}

// The search bar has an ugly white gap above it. This removes it
// This is part of the SearchBarDelegate protocol.
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
  return UIBarPositionTopAttached;
}

// takes the NSURL object as a parameter and returns the JSON data that is received from the server.
- (NSString *)performStoreRequestWithURL:(NSURL *)url {
  NSError *error;
  // a convenience constructor of the NSString class that returns a new string object with the data that it receives from the server at the other end of the URL. If something goes wrong, the string is nil and the NSError variable contains more details about the error.
  NSString *resultString =
      [NSString stringWithContentsOfURL:url
                               encoding:NSUTF8StringEncoding
                                  error:&error];
  if (resultString == nil) {
    NSLog(@"Download Error: %@", error);
    return nil;
  }
  return resultString;
}

// This will convert a json string to a json object
- (NSDictionary *)parseJSON:(NSString *)jsonString {
  // Because the JSON data is actually in the form of a string, you have to put it into an NSData object first.
  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  //  NSJSONSerialization class here to convert the JSON search results to an NSDictionary.
  id resultObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&error];
  if (resultObject == nil) {
    NSLog(@"JSON Error: %@", error);
    return nil;
  }
    
// Just because NSJSONSerialization was able to turn the string into valid Objective-C objects, doesn’t mean that it returns an NSDictionary! It could have returned an NSArray or even an NSString or NSNumber... In the case of the iTunes store web service, the top-level object should be an NSDictionary, but you can’t control what happens on the server. If for some reason the server programmers decide to put [ ] brackets around the JSON data, then the top-level object will no longer be an NSDictionary but an NSArray.
  if (![resultObject isKindOfClass:[NSDictionary class]]) {
    NSLog(@"JSON Error: Expected dictionary");
    return nil;
  }
    
  return resultObject;
}

// Helper that creates and shows up alert
// We use this when our requests don;t work
- (void)showNetworkError {
  UIAlertView *alertView =
      [[UIAlertView alloc] initWithTitle:@"Whoops..."
                                 message:@"There was an error reading from the "
                                         @"iTunes Store. Please try again."
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
  [alertView show];
}

@end
