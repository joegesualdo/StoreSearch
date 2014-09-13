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
#import "LandscapeViewController.h"
#import "Search.h"

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
    Search *_search;
    
    LandscapeViewController *_landscapeViewController;
    // This variable keeps track of whether the status bar should be black (“default”) or white (“light content”).
    UIStatusBarStyle _statusBarStyle;
    // this pointer is no longer keeping the object alive and as soon as the object is deallocated, _detailViewController automatically becomes nil.
    // if we didn't put this, then the detailViewcontroller would stay alive since this instnance varaible was strongly pointing to it
    __weak DetailViewController *_detailViewController;
}

// DONT NEED ANYMORE
//// In previous tutorials you used initWithCoder: but here the view controller is not loaded from a storyboard or nib (only its view is). Look inside AppDelegate.m if you don’t believe me. There you’ll see the line that calls initWithNibName:bundle: to create and initialize the SearchViewController object. So that is the proper init method to add this code to.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//      // You will create this _queue object when the view controller gets instantiated, in other words in its init method.
//      _queue = [[NSOperationQueue alloc] init];
//    }
//    return self;
//}

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
    
    // give this variable an initial value
    _statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (_search == nil) {
    return 0; // Not searched yet
  } else if (_search.isLoading) {
    return 1; // Loading...
  } else if ([_search.searchResults count] == 0) {
    return 1; // Nothing Found }
  } else {
    return [_search.searchResults count];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // only make a SearchResultCell if there are actually any results. If the array is empty, you’ll simply dequeue the cell for the NothingFoundCellIdentifier and return it
    
  // search results are loading, we will show the Loading cell
    NSLog(@"_isLoading -- %hhd", _search.isLoading);
  if (_search.isLoading) {
      UITableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:LoadingCellIdentifier
                               forIndexPath:indexPath];
      // It also looks up the UIActivityIndicatorView by its tag
      UIActivityIndicatorView *spinner =
      (UIActivityIndicatorView *)[cell viewWithTag:100];
      // tells the spinner to start animating.
      [spinner startAnimating];
      return cell;
  }else if ([_search.searchResults count] == 0) {
    return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                        forIndexPath:indexPath];
  } else {
    SearchResultCell *cell = (SearchResultCell *)
        [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier
                                        forIndexPath:indexPath];
    NSUInteger row = (NSUInteger) indexPath.row;
    SearchResult *searchResult = _search.searchResults[row];
      
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
    SearchResult *searchResult = _search.searchResults[indexPath.row];
    controller.searchResult = searchResult;
    
    [controller presentInParentViewController:self];
    
    _detailViewController = controller;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
    willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // makes sure that you can only select rows with actual search results, not the loading cell or nothing found cell
  if ([_search.searchResults count] == 0 || _search.isLoading) {
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

- (void)performSearch {
  _search = [[Search alloc] init];
  NSLog(@"allocated %@", _search);
  //  pass a completion block to the performSearchForText method. The code in this block gets called after the search completes, with the success parameter being either YES or NO. A lot simpler than making a delegate, no? This block is always called on the main thread, so it’s safe to can use UI code here.
  [_search performSearchForText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex completion:^(BOOL success) {
      if (!success) {
          [self showNetworkError];
      }
      // This will stop the spinner
      [_landscapeViewController searchResultsReceived];
      [self.tableView reloadData];
  }];
  [self.tableView reloadData];
  [self.searchBar resignFirstResponder];
}

// DO NOT NEED ANY MORE
//-(void)performSearch
//{
//  if ([self.searchBar.text length] > 0) {
//    [self.searchBar resignFirstResponder];
//      
//    // Every time the user performs a new search you cancel the previous request
//    // cancel everything that is in a que
//    [_queue cancelAllOperations];
//    _isLoading = YES;
//    [self.tableView reloadData];
//    _searchResults = [NSMutableArray arrayWithCapacity:10];
//    NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex];
//    // After you’ve created the NSURL object like before, you now put it into an NSURLRequest object.
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    //  You use that request object to create a new AFHTTPRequestOperation object.
//    AFHTTPRequestOperation *operation =
//        [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    // As you can see, AFHTTPRequestOperation takes two blocks, one for success and one for failure.
//    // The code in the success block is executed when everything goes right, while the code from the failure block gets executed if there is some problem making the request or when the response isn’t valid JSON.
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation,
//                                               id responseObject) {
//        // This takes the object from the responseObject parameter, which is actually an NSDictionary, and calls parseDictionary: to turn its contents into SearchResult objects, just like you did before.
//        [self parseDictionary:responseObject];
//        // sort the results and put everything into the table.
//        [_searchResults sortUsingSelector:@selector(compareName:)];
//        //hide the loading cell
//        _isLoading = NO;
//        // reload table
//        [self.tableView reloadData];
//    } failure:^(AFHTTPRequestOperation *operation,
//                NSError *error) {
//        
//        // Canceling an AFHTTPRequestOperation invokes its failure block, so add these lines to the failure block to prevent the app from showing an error message. Becuase above, if you user searched for something else before the results are returned, the operation is cancelled
//        if (operation.isCancelled) {
//          return;
//        }
//        // howNetworkError message to tell the user that something went wrong.
//        [self showNetworkError];
//        //hide the loading cell
//        _isLoading = NO;
//        // reload table
//        [self.tableView reloadData];
//    }];
//    [_queue addOperation:operation];
//  }
//}



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

// We hookup the segment control up to this IBAction, so whenever the tab changes, this method is called
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
// The app will always call performSearch if the user presses the Search button on the keyboard, but in the case of tapping on the Segmented Control it will only do a new search if the user has already performed a search before.
  if (_search != nil) {
    [self performSearch];
  }
    NSLog(@"Woooo");
}

// This is a delegate method that is called when the phone is about to rotate
//  When a view controller is about to be flipped over, it will let you know with this method. You can override it to show (and hide) the new LandscapeViewController.
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    NSLog(@"Did Rotate");
  if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
      [self hideLandscapeViewWithDuration:duration];
  } else {
    [self showLandscapeViewWithDuration:duration];
  }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration {
  if (_landscapeViewController == nil) {
    //Hide keyboard when entering landscape mode
    [self.searchBar resignFirstResponder];
    // dismiss the detail view if you swith to landscape mode
    [_detailViewController dismissFromParentViewController];
    //  First you create the new view controller object,
    _landscapeViewController = [[LandscapeViewController alloc]
        initWithNibName:@"LandscapeViewController"
                 bundle:nil];
    // pass the results to the landscape view
    _landscapeViewController.search = _search;
    //  then you set the frame size of its view
    _landscapeViewController.view.frame = self.view.bounds;
    // LandscapeViewController starts out completely see-through (alpha = 0.0)
    _landscapeViewController.view.alpha = 0.0f;
    // Add it as a subview
    [self.view addSubview:_landscapeViewController.view];
    // embedding the view controller into the hierarchy so it will get all necessary callback events.
    [self addChildViewController:_landscapeViewController];
    
    // slowly fades in lanscapeviewcontrollerwhile the rotation takes place until it’s completely visible (alpha = 1.0).
      [UIView animateWithDuration:duration animations:^{
          _landscapeViewController.view.alpha = 1.0f;
          
          // this changes the value of _statusBarStyle and then tells the view controller to update the appearance of the status bar. This causes the preferredStatusBarStyle method to be re-evaluated and the status bar will redraw itself in the new color.
          _statusBarStyle = UIStatusBarStyleLightContent;
          [self setNeedsStatusBarAppearanceUpdate];
          
      } completion:^(BOOL finished) {
          // Notice that you delay the call to didMoveToParentViewController: until the animation is completed.
          [_landscapeViewController didMoveToParentViewController:self];
      }];
  }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration {
  if (_landscapeViewController != nil) {
    [_landscapeViewController willMoveToParentViewController:nil];
      
      // This time you fade out the view (back to alpha = 0.0).
      [UIView animateWithDuration:duration animations:^{
          // This time you fade out the view (back to alpha = 0.0).
          _landscapeViewController.view.alpha = 0.0f;
          
          // this changes the value of _statusBarStyle and then tells the view controller to update the appearance of the status bar. This causes the preferredStatusBarStyle method to be re-evaluated and the status bar will redraw itself in the new color.
          _statusBarStyle = UIStatusBarStyleDefault;
          [self setNeedsStatusBarAppearanceUpdate];
          
      } completion:^(BOOL finished) {
          // You don’t remove the view and the controller until the animation is completely done.
          [_landscapeViewController.view removeFromSuperview];
          [_landscapeViewController removeFromParentViewController];
        // explicitly set the instance variable to nil in order to deallocate the LandscapeViewController object now that you’re done with it.
          _landscapeViewController = nil;
      }];
  }
}

// This method is called by UIKit to determine what color to make the status bar.
// can trigger this method with setNeedsStatusBarAppearanceUpdate:
// [self setNeedsStatusBarAppearanceUpdate];
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}
@end
