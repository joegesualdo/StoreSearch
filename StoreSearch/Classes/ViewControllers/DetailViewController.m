//
//  DetailViewController.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/11/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

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
@end