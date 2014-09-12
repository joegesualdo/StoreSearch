//
//  DetailViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/11/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"

@interface DetailViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, weak) IBOutlet UIView *popupView;
@property(nonatomic, weak) IBOutlet UIImageView *artworkImageView;

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *kindLabel;
@property(nonatomic, weak) IBOutlet UILabel *genreLabel;
@property(nonatomic, weak) IBOutlet UIButton *priceButton;

@end

@implementation DetailViewController

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
    // Do any additional setup after loading the view from its nib.
    
    // We are setting the tranparency of the parent view through code because alpa was being passed to child views
    [self.view setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
    
    // each view has one, and that layers have some handy properties (like cornerRadius)
    // To use these properties must import <QuartzCore/QuartzCore.h>
    // set a border radius to the popview
    self.popupView.layer.cornerRadius = 10.0f;
    
    // creates a new gesture recognizer that listens to taps anywhere in this view controller and calls the close: method in response.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    
    // ??? what does this mean
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:gestureRecognizer];
    
    if (self.searchResult != nil) {
      [self updateUI];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
  //Make sure the following 3 methods are called in order, or you will get a nasty crash
  // First you call willMoveToParentViewController: to tell the view controller that it is leaving the view controller hierarchy (it no longer has a parent)
  [self willMoveToParentViewController:nil];
  // then you remove its view from the screen
  [self.view removeFromSuperview];
  // call removeFromParentViewController to truly dispose of the view controller.
  [self removeFromParentViewController];
}

// Whenever I write a new view controller, I like to put an NSLog() in its dealloc method just to make sure the object is properly deallocated when the screen closes.
- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

#pragma mark - UIGesture delegates
// This only returns YES when the touch was on the background view but NO if it was inside the Popup View.
- (BOOL)gestureRecognizer: (UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
  return (touch.view == self.view);
}

//logic for setting the text on the labels has its own method
- (void)updateUI {
    
  self.kindLabel.text = [self.searchResult kindForDisplay];
  self.nameLabel.text = self.searchResult.name;
  NSString *artistName = self.searchResult.artistName;
  if (artistName == nil) {
    artistName = @"Unknown";
  }
  self.artistNameLabel.text = artistName;
  self.kindLabel.text = self.searchResult.kind;
  self.genreLabel.text = self.searchResult.genre;
    
  // You’ve used NSDateFormatter in previous tutorials to turn an NSDate object into human-readable text. Here you use NSNumberFormatter to do the same thing for numbers. It’s possible, of course, to turn a number into a string using stringWithFormat: and the right format specifier such as @"%f" or @"%d". However, in this case you’re not dealing with regular numbers but with money in a certain currency.
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  // You simply tell the NSNumberFormatter that you want to display a currency value and what the currency code is. That currency code comes from the web service and is something like “USD” or “EUR”. The NSNumberFormatter will insert the proper symbol, such as $ or € or ¥, and formats the monetary amount according to the user’s regional settings.
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setCurrencyCode:self.searchResult.currency];
  NSString *priceText;
  if ([self.searchResult.price floatValue] == 0.0f) {
    priceText = @"Free";
  } else {
    priceText = [formatter stringFromNumber:self.searchResult.price];
  }
    
  [self.priceButton setTitle:priceText forState:UIControlStateNormal];
}

// The web service returned a URL to the product page. You simply tell the UIApplication object to open this URL. iOS will now figure out what sort of URL it is and launch the proper app – iTunes Store, App Store, Mobile Safari – in response.
// If you run this on the Simulator, you’ll probably receive an error message that the URL could not be opened. Try it on your device instead.
- (IBAction)openInStore:(id)sender {
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:self.searchResult.storeURL]];
}

@end
