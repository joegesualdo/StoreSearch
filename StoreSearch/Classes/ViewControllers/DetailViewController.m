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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GradientView.h"

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
{
    GradientView *_gradientView;
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
    // Do any additional setup after loading the view from its nib.
    
    
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
  [self dismissFromParentViewController];
}

- (void)dismissFromParentViewController
{
  //Make sure the following 3 methods are called in order, or you will get a nasty crash
  // First you call willMoveToParentViewController: to tell the view controller that it is leaving the view controller hierarchy (it no longer has a parent)
  [self willMoveToParentViewController:nil];

  // Make a short animation before the view and the view controller truly get removed from the parent controller.
  // WE want the popup to drop off the screen when we close it AND the gradient to fade out
  [UIView animateWithDuration:0.3
      animations:^{
          // You also animate the gradient view by setting its alpha value to 0, which will fade it out. That’s essentially the reverse of what you did earlier except that the property is now called “alpha” instead of “opacity” (that’s one of the small differences between doing UIView-based animation and Core Animation; you gotta love it).
          // First you get the view’s bounds, which describe a rectangle,
          CGRect rect = self.view.bounds;
          // then you change the Y coordinate of that rectangle
          rect.origin.y += rect.size.height;
          // finally you assign this new rectangle to the view’s frame.
          self.view.frame = rect;
          // You also animate the gradient view by setting its alpha value to 0, which will fade it out. That’s essentially the reverse of what you did earlier except that the property is now called “alpha” instead of “opacity” (that’s one of the small differences between doing UIView-based animation and Core Animation; you gotta love it).
          _gradientView.alpha = 0.0f;
      }
      completion:^(BOOL finished) {
          // then you remove its view from the screen
          [self.view removeFromSuperview];
          // call removeFromParentViewController to truly dispose of the view controller.
          [self removeFromParentViewController];
          // remove the gradient view when the pop-up gets dismissed.
          [_gradientView removeFromSuperview];
      }];
}

// Whenever I write a new view controller, I like to put an NSLog() in its dealloc method just to make sure the object is properly deallocated when the screen closes.
- (void)dealloc {
    // cancel the image download if the user closes the pop-up before the image has been downloaded completely.
    NSLog(@"dealloc %@", self);
    [self.artworkImageView cancelImageRequestOperation];
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
    
  [self.artworkImageView setImageWithURL:
   [NSURL URLWithString:self.searchResult.artworkURL100]];
    
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

- (void)presentInParentViewController:(UIViewController *)parentViewController {
  // You create a new GradientView object by hand that is just as big as the view from the parent view controller.
  _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
  //add the _gradientView it as a subview to that parent view controller.
  // doing this before you add DetailViewController’s view to the parent view controller, which causes the GradientView to sit below the pop- up, which is exactly where you want it.
  [parentViewController.view addSubview:_gradientView];
    
  self.view.frame = parentViewController.view.bounds;
  // First, add the new view controller’s view as a subview. This places it on top of the table view, search bar and segmented control.
  [parentViewController.view addSubview:self.view];
  // Then tell the SearchViewController that the DetailViewController is now managing that part of the screen, using addChildViewController:. If you forget this step then the new view controller may not always work correctly, as I shall demonstrate in a short while.
  [parentViewController addChildViewController:self];
  // create a CAKeyframeAnimation object that works on the view’s transform.scale attributes. That means you’ll be animating the size of the view.
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  // The animation consists of several keyframes. It will smoothly proceed from one keyframe to the other over a certain amount of time. The values for the keyframes are added to the animation’s values property. Because you’re animating the view’s scale, these particular values represent how much bigger or smaller the view will be over time.
  bounceAnimation.duration = 0.4;
  bounceAnimation.delegate = self;
  // By quickly changing the view size from small to big to small to normal, you create a bounce effect.
  // The animation starts with the view scaled down to 70% (scale 0.7). The next keyframe inflates it to 120% its normal size. After that, it will scale the view down a bit again but not as much as before (only 90% of its original size), and the last keyframe ends up with a scale of 1.0, which restores the view to an undistorted shape.
  bounceAnimation.values = @[ @0.7, @1.2, @0.9, @1.0 ];
  // For each keyframe you can also specify a time. You can see this as the duration between two successive keyframes. In this case, each transition from one keyframe to the next takes 1/3rd of the total animation time. Note that these times are not in seconds but in fractions of the animation’s duration. The total duration is 0.4 seconds.
  bounceAnimation.keyTimes = @[ @0.0, @0.334, @0.666, @1.0 ];
    // ou can also specify a timing function that is used to go from one keyframe to the next. I chose to use the “Ease In, Ease Out” function, which starts slowly, then ramps up to full speed, and then slows down again. You can also choose just “Ease In” (think accelerating) or “Ease Out” (think decelerating) or a linear interpolation, but the latter doesn’t tend to look very realistic. Moving objects in real-life always need some time to get started or slow down and that is what the timing function does.
  bounceAnimation.timingFunctions = @[
    [CAMediaTimingFunction
        functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
    [CAMediaTimingFunction
        functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
  ];
    
  // This is a simple CABasicAnimation that animates the _gradientView’s opacity value from 0.0 (fully see-through) to 1.0 (fully visible) in 0.2 seconds, resulting in a simple fade-in. That’s a bit more subtle than making the view appear so abruptly.
  CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeAnimation.fromValue = @0.0f;
  fadeAnimation.toValue = @1.0f;
  fadeAnimation.duration = 0.2;
  [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];

  // Finally, you add the animation to the view’s layer. Core Animation doesn’t work on the UIView objects themselves but on their CALayers.
  [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}

// You also set the animation’s delegate. You need to know when the animation stops because at that point you must call the didMoveToParentViewController: method. That’s part of the three steps of embedding one view controller into another, remember? By making DetailViewController the delegate of the CAKeyframeAnimation, you will be told when the animation stopped.
// Note that for this Core Animation delegate there is no need to put a protocol declaration into the @interface line. CAKeyframeAnimation doesn’t use a formal protocol for its delegate. All you need to do is implement the animationDidStop:finished: method and you’re done.
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  // Tell the new view controller that it now has a parent view controller with didMoveToParentViewController:.
  // So you’re always responsible for calling this method on the child view controller once the animation completes. Don’t forget this; it’s part of the rules for embedding view controllers.
  [self didMoveToParentViewController: self.parentViewController];
}

@end
