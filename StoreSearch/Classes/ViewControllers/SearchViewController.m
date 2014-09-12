//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "DetailViewController.h"

// This defines a symbolic name, SearchResultCellIdentifier, with the value @"SearchResultCell". Should you want to change this value, then you only have to do it here and any code that uses SearchResultCellIdentifier will be automatically updated.
// There is another reason for using a symbolic name rather than the actual value: it gives extra meaning. Just seeing the text @"SearchResultCell" says less about its intended purpose than the word SearchResultCellIdentifier.
static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

// hook up the data source and delegate protocols yourself.
@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

// Why do we make the IBOutlets weak?
// Recall that as soon as an object no longer has any strong pointers, it goes away (it is deallocated) and all the weak pointers become nil. Per Apple’s recommendation you’ve been making your outlets weak pointers. You may be wondering, if the pointers to these view objects are weak, then won’t the objects get deallocated too soon?
// Answer: Views are always part of a view hierarchy and they will always have an owner with a strong pointer: their superview. In this screen, the SearchViewController’s main view object will hold a reference to both the search bar and the table view. This is done inside UIKit and you don’t have to worry about it. As long as the view controller exists, so will these two outlets.
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;


@end

@implementation SearchViewController
{
    // instance variables
    NSMutableArray *_searchResults;
    // tells if the search is loading
    BOOL _isLoading;
    NSOperationQueue *_queue;
}

// In previous tutorials you used initWithCoder: but here the view controller is not loaded from a storyboard or nib (only its view is). Look inside AppDelegate.m if you don’t believe me. There you’ll see the line that calls initWithNibName:bundle: to create and initialize the SearchViewController object. So that is the proper init method to add this code to.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // You will create this _queue object when the view controller gets instantiated, in other words in its init method.
      _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar. Now the first row will always be visible, and when you scroll the table view the cells still go under the search bar. Nice.
    // Before putting this, the top cells in the table view were cut off.
    // This 108 inset, leaves a margin on top so the navbar wont cover any cells
    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    
    // The UINib class is used to load nibs. Here you tell it to load the nib you just created (note that you don’t specify the .xib file extension). Then you ask the table view to register this nib for the reuse identifier “SearchResultCell”.
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
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
    
    // If results are loading, return once cell, because that cell wll have the "Loading" symbl
    if (_isLoading) {
        return 1;
    }else if (_searchResults == nil) {
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
    
  // search results are loading, we will show the Loading cell
    NSLog(@"_isLoading -- %hhd", _isLoading);
  if (_isLoading) {
      UITableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:LoadingCellIdentifier
                               forIndexPath:indexPath];
      // It also looks up the UIActivityIndicatorView by its tag
      UIActivityIndicatorView *spinner =
      (UIActivityIndicatorView *)[cell viewWithTag:100];
      // tells the spinner to start animating.
      [spinner startAnimating];
      return cell;
  }else if ([_searchResults count] == 0) {
    return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                        forIndexPath:indexPath];
  } else {
    SearchResultCell *cell = (SearchResultCell *)
        [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier
                                        forIndexPath:indexPath];
    NSUInteger row = (NSUInteger) indexPath.row;
    SearchResult *searchResult = _searchResults[row];
      
    // we now configure the cell with the method we created in SearchREsultCell
    [cell configureForSearchResult:searchResult];
      
    return cell;
  }
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Removes the keyboard if it's on the screen
    [self.searchBar resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Because this app uses nibs and not storyboards, you cannot make segues by drawing an array between two different view controllers. To show a new view controller you have to alloc and init it yourself and then present it. This is the equivalent of making a modal segue.
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName: @"DetailViewController" bundle:nil];
    
    // look up the SearchResult object and put it in DetailViewController’s property.￼
    SearchResult *searchResult = _searchResults[indexPath.row];
    controller.searchResult = searchResult;
    
    controller.view.frame = self.view.frame;
    
    // First, add the new view controller’s view as a subview. This places it on top of the table view, search bar and segmented control.
    [self.view addSubview:controller.view];
    // Then tell the SearchViewController that the DetailViewController is now managing that part of the screen, using addChildViewController:. If you forget this step then the new view controller may not always work correctly, as I shall demonstrate in a short while.
    [self addChildViewController:controller];
    // Tell the new view controller that it now has a parent view controller with didMoveToParentViewController:.
    [controller didMoveToParentViewController:self];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // makes sure that you can only select rows with actual search results, not the loading cell or nothing found cell
  if ([_searchResults count] == 0 || _isLoading) {
    return nil;
  } else {
    return indexPath;
  }
}

#pragma mark - UISearchBarDelegate
// is invoked when the user taps the Search button on the keyboard.


// this delegate method will will put some fake data into this array and then use it to fill up the table.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
}

-(void)performSearch
{
  if ([self.searchBar.text length] > 0) {
    [self.searchBar resignFirstResponder];
      
    // Every time the user performs a new search you cancel the previous request
    // cancel everything that is in a que
    [_queue cancelAllOperations];
    _isLoading = YES;
    [self.tableView reloadData];
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex];
    // After you’ve created the NSURL object like before, you now put it into an NSURLRequest object.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //  You use that request object to create a new AFHTTPRequestOperation object.
    AFHTTPRequestOperation *operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    // As you can see, AFHTTPRequestOperation takes two blocks, one for success and one for failure.
    // The code in the success block is executed when everything goes right, while the code from the failure block gets executed if there is some problem making the request or when the response isn’t valid JSON.
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation,
                                               id responseObject) {
        // This takes the object from the responseObject parameter, which is actually an NSDictionary, and calls parseDictionary: to turn its contents into SearchResult objects, just like you did before.
        [self parseDictionary:responseObject];
        // sort the results and put everything into the table.
        [_searchResults sortUsingSelector:@selector(compareName:)];
        //hide the loading cell
        _isLoading = NO;
        // reload table
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation,
                NSError *error) {
        
        // Canceling an AFHTTPRequestOperation invokes its failure block, so add these lines to the failure block to prevent the app from showing an error message. Becuase above, if you user searched for something else before the results are returned, the operation is cancelled
        if (operation.isCancelled) {
          return;
        }
        // howNetworkError message to tell the user that something went wrong.
        [self showNetworkError];
        //hide the loading cell
        _isLoading = NO;
        // reload table
        [self.tableView reloadData];
    }];
    [_queue addOperation:operation];
  }
}


- (NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category
{
  NSString *categoryName;
    
  // This first turns the category index from a number into a string. (Note that the category index is passed to the method as a new parameter.)
  switch (category) {
    // For the first tab  of the segmented control -- "ALL"
    case 0:
      categoryName = @"";
      break;
    // For the second tab  of the segmented control -- "Music"
    case 1:
      categoryName = @"musicTrack";
      break;
    // For the third tab  of the segmented control -- "Software"
    case 2:
      categoryName = @"software";
      break;
    // For the fourth tab  of the segmented control -- "E-books"
    case 3:
      categoryName = @"ebook";
      break;
  }
  //  A space is not a valid character in a URL. Many other characters aren’t valid either (such as the < or > signs) and therefore must be escaped. Another term for this is URL encoding. A space, for example, can be encoded as the + sign (you did that earlier when you typed the URL into the web browser) or as the character sequence %20.
  // Fortunately, NSString can do this encoding already,
    // stringbyAddingPercentEscapesUsingEcoding method escaped all the spaces by putting %20
  NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlString = [NSString
      stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, categoryName];
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

// method goes through the top-level NSDictionary and looks at each search result in turn. If it’s a type of product the app supports, then it creates a SearchResult object for that product and adds it to the searchResults array.
- (void)parseDictionary:(NSDictionary *)dictionary {
  // makes sure the dictionary contains a key named results that contains an NSArray.
  NSArray *array = dictionary[@"results"];
  if (array == nil) {
    NSLog(@"Expected 'results' array");
    return;
  }
  // look at each of the array’s elements in turn. Remember that each of the elements from the array is another NSDictionary. For each of these dictionaries, you print out the value of its wrapperType and kind fields.
  for (NSDictionary *resultDict in array) {
    SearchResult *searchResult;
    NSString *wrapperType = resultDict[@"wrapperType"];
    NSString *kind = resultDict[@"kind"];
    if ([wrapperType isEqualToString:@"track"]) {
      // we created the parseTrack method below
      searchResult = [self parseTrack:resultDict];
    } else if ([wrapperType isEqualToString:@"audiobook"]) {
      searchResult = [self parseAudioBook:resultDict];
    } else if ([wrapperType isEqualToString:@"software"]) {
      searchResult = [self parseSoftware:resultDict];
    // For some reason, e-books do not have a wrapperType field, so in order to determine whether something is an e-book you have to look at the kind field instead.
    } else if ([kind isEqualToString:@"ebook"]) {
      searchResult = [self parseEBook:resultDict];
    }
    if (searchResult != nil) {
      [_searchResults addObject:searchResult];
    }
  }
}

// You first allocate a new SearchResult object and then get the values out of the dictionary and put them in the SearchResult’s properties.
- (SearchResult *)parseTrack:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"trackPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}

- (SearchResult *)parseAudioBook:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"collectionName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"collectionViewUrl"];
  // Audio books don’t have a “kind” field, so you have to set the kind property to @"audiobook" yourself.
  searchResult.kind = @"audiobook";
  searchResult.price = dictionary[@"collectionPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}
- (SearchResult *)parseSoftware:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}
- (SearchResult *)parseEBook:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  // E-books don’t have a “primaryGenreName” field, but an array of genres. You use the componentsJoinedByString method from NSArray to glue these genre names into a single string, separated by commas.
  searchResult.genre =
      [(NSArray *)dictionary[@"genres"] componentsJoinedByString:@", "];
  return searchResult;
}

// We hookup the segment control up to this IBAction, so whenever the tab changes, this method is called
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
// The app will always call performSearch if the user presses the Search button on the keyboard, but in the case of tapping on the Segmented Control it will only do a new search if the user has already performed a search before.
  if (_searchResults != nil) {
    [self performSearch];
  }
    NSLog(@"Woooo");
}

@end
