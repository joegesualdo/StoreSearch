//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/12/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"

@interface LandscapeViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation LandscapeViewController
{
    BOOL _firstTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // first you put an image on the scroll view’s background so you can actually see something happening when you scroll through it.
    // An image? But you’re setting the backgroundColor property, which is a UIColor, not a UIImage?! Yup, that’s true, but UIColor has a cool trick that lets you use a tile- able image for a color. If you take a peek at the LandscapeBackground.png image in the asset catalog you’ll see that it is a small square. By setting this image as a pattern image on the background, you get a repeatable image that fills the whole screen. You can use tile-able images anywhere you can use a UIColor.
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"LandscapeBackground"]];
}

// The only safe place to perform calculations based on the final size of the view (i.e. any calculations that use the view’s frame or bounds) is in viewWillLayoutSubviews.
- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  // This viewWillLayoutSubviews method may be invoked more than once; for example, when the landscape view gets removed from the screen again. You use the _firstTime variable to make sure you only place the buttons once.
  if (_firstTime) {
    _firstTime = NO;
    //  that performs the math and places the buttons on the screen in neat rows and columns. This needs to happen just once, when the LandscapeViewController is added to the screen.
    [self tileButtons];
  }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// add a dealloc method, just so you can see that the view controller truly gets deallocated
- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

// that performs the math and places the buttons on the screen in neat rows and columns. This needs to happen just once, when the LandscapeViewController is added to the screen.
- (void)tileButtons {
  // The columnsPerPage variable keeps track of how many columns will fit in a single screenful of buttons. The number of columns on a 4-inch screen is 6 but 568 doesn’t evenly divide by 6, so the extraSpace variable is used to adjust for the 4 points that are left over.
  int columnsPerPage = 5;
  CGFloat itemWidth = 96.0f;
  CGFloat x = 0.0f;
  CGFloat extraSpace = 0.0f;
  CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
  if (scrollViewWidth > 480.0f) {
    columnsPerPage = 6;
    itemWidth = 94.0f;
    x = 2.0f;
    extraSpace = 4.0f;
  }
  const CGFloat itemHeight = 88.0f;
  const CGFloat buttonWidth = 82.0f;
  const CGFloat buttonHeight = 82.0f;
  const CGFloat marginHorz = (itemWidth - buttonWidth) / 2.0f;
  const CGFloat marginVert = (itemHeight - buttonHeight) / 2.0f;
    
  int index = 0;
  int row = 0;
  int column = 0;
    
  // Now you can loop through the array of search results and make a new button for each SearchResult object:
  for (SearchResult *searchResult in self.searchResults) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    // For debugging purposes you give each button a title with an index, counting from 0. If there are 200 results in the search, you also should end up with 200 buttons. Setting the index on the button will help to verify this.
    [button setTitle:[NSString stringWithFormat:@"%d", index]
            forState:UIControlStateNormal];
     // When you make a button by hand you always have to set its frame. Using the stuff you figured out earlier you can determine the position and size of the button.
    button.frame =
        CGRectMake(x + marginHorz, 20.0f + row * itemHeight + marginVert, buttonWidth, buttonHeight);
    //You add the new button object as a subview to the UIScrollView. After the first 15 buttons (or 18 on 4-inch) this places any subsequent button out of the visible range of the scroll view, but that’s the whole point. As long as you set the contentSize accordingly, the user can scroll to get to those other buttons.
    [self.scrollView addSubview:button];
    // You use the x and row variables to position the buttons. You go from top to bottom (by increasing row);
    index++;
    row++;
    // when you’ve reached the bottom (row 3) you go up again and skip to the next column (by increasing the column variable).
    if (row == 3) {
      row = 0;
      column++;
      x += itemWidth;
      // When the column reaches the end of the screen (equals columnsPerPage), you reset it to 0 and add the left-over space to x. This only has an effect on 4-inch screens because for 3.5-inch screens extraSpace is 0.
      if (column == columnsPerPage) {
        column = 0;
        x += extraSpace;
      }
    }
  }
  // you calculate the contentSize. We want the user to be able to “page” through these results, rather than simply scroll (a feature that you’ll enable shortly) so you should always make the content width a multiple of 480 or 568 points (the width of a single page). With a simple formula you can determine how many pages you need.
  int tilesPerPage = columnsPerPage * 3;
  int numPages = ceilf([self.searchResults count] / (float)tilesPerPage);
  self.scrollView.contentSize = CGSizeMake(numPages *scrollViewWidth, self.scrollView.bounds.size.height);

  NSLog(@"Number of pages: %d", numPages);
}

@end
