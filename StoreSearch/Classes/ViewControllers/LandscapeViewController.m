//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/12/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "LandscapeViewController.h"

@interface LandscapeViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation LandscapeViewController

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
    
    // first you put an image on the scroll view’s background so you can actually see something happening when you scroll through it.
    // An image? But you’re setting the backgroundColor property, which is a UIColor, not a UIImage?! Yup, that’s true, but UIColor has a cool trick that lets you use a tile- able image for a color. If you take a peek at the LandscapeBackground.png image in the asset catalog you’ll see that it is a small square. By setting this image as a pattern image on the background, you get a repeatable image that fills the whole screen. You can use tile-able images anywhere you can use a UIColor.
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"LandscapeBackground"]];
    // The second thing, and this is very important when dealing with scroll views, is that you set the contentSize property. This will tell the scroll view how big its insides are. You don’t change the frame (or bounds) of the scroll view if you want its insides to be bigger, you set the contentSize property instead. People often forget this step and then they wonder why their scroll view doesn’t scroll. Unfortunately, you cannot do this from Interface Builder, so it must be done from within the code.
    self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
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

@end
