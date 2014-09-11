//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// The awakeFromNib method is called immediately after this cell object has been loaded from the nib. You can use it to do additional initialization. Why don’t you do that in an init method, such as initWithCoder:? No particular reason, I just wanted to show you that awakeFromNib existed (it’s also less typing!).
// It’s worth noting that awakeFromNib is called some time after initWithCoder: and after all of the other objects from the nib have been created. For example, in initWithCoder: the self.nameLabel outlet will still be nil but in awakeFromNib it will be properly hooked up to the corresponding UILabel object.
- (void)awakeFromNib {
  // Don’t forget to first call [super awakeFromNib], which is required. If you forget, then the superclass UITableViewCell (or any of the other superclasses) may not get a chance to initialize themselves. It’s always a good idea to call [super methodName] in a method that you’re overriding (such as viewDidLoad, viewWillAppear:, and so on), unless the documentation says otherwise.
  [super awakeFromNib];
  // A rectangle constant with location (0,0), and width and height of 0. The zero rectangle is equivalent to CGRectMake(0,0,0,0).
  UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    // This will define the solor of the background when a cell is selected (instead of the standard gray)
  selectedView.backgroundColor = [UIColor colorWithRed:20 / 255.0f
                                                 green:160 / 255.0f
                                                  blue:160 / 255.0f
                                                 alpha:0.5f];
    // This will set the view we created as the background, so this will be the background when we select a cell, instea of the standard gray
  self.selectedBackgroundView = selectedView;
}

@end
