//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
// Remember that a category can be used to extend the functionality of an existing class and that’s exactly what AFNetworking’s developers did. Because loading images and showing them in UIImageViews is a very common thing, they provided this really convenient category that lets you pull this off with just one line of code.
#import <AFNetworking/UIImageView+AFNetworking.h>

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

- (void)configureForSearchResult:(SearchResult *)searchResult {
  self.nameLabel.text = searchResult.name;
  NSString *artistName = searchResult.artistName;
  if (artistName == nil) {
    artistName = @"Unknown";
  }
  NSString *kind = [self kindForDisplay:searchResult.kind];
  self.artistNameLabel.text =
      [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
    
  // This tells AFNetworking to load the image from artworkURL60 and to place it in the cell’s image view. While the image is loading the image view displays the placeholder image that you added to the asset catalog earlier.
  [self.artworkImageView setImageWithURL:
   [NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

//  The value of kind comes straight from the server and it is more of an internal name than something you’d want to show directly to the user.
// This helper lets us change the name for kind
- (NSString *)kindForDisplay:(NSString *)kind {
  if ([kind isEqualToString:@"album"]) {
    return @"Album";
  } else if ([kind isEqualToString:@"audiobook"]) {
    return @"Audio Book";
  } else if ([kind isEqualToString:@"book"]) {
    return @"Book";
  } else if ([kind isEqualToString:@"ebook"]) {
    return @"E-Book";
  } else if ([kind isEqualToString:@"feature-movie"]) {
    return @"Movie";
  } else if ([kind isEqualToString:@"music-video"]) {
    return @"Music Video";
  } else if ([kind isEqualToString:@"podcast"]) {
    return @"Podcast";
  } else if ([kind isEqualToString:@"software"]) {
    return @"App";
  } else if ([kind isEqualToString:@"song"]) {
    return @"Song";
  } else if ([kind isEqualToString:@"tv-episode"]) {
    return @"TV Episode";
  } else {
    return kind;
  }
}

//Remember that table view cells can be reused, so it’s theoretically possible that you’re scrolling through the table and some cell is about to be reused while its previous image is still loading. You no longer need that image so you should really cancel the pending download. Table view cells have a special method named prepareForReuse that is ideal for this.
// prepareForResuse is called every time we are about to reuse a cell
// Here you cancel any image download that is still in progress and for good measure you also clear out the text from the labels. It’s always a good idea to play nice.
- (void)prepareForReuse {
  [super prepareForReuse];
  // this will cancel the image request from the last cell if it wasn't fulfilled yet. This way we don't have this old image overriding our new one
  [self.artworkImageView cancelImageRequestOperation];
  // resets nameLable text to nothing
  self.nameLabel.text = nil;
  // resets artistNameLabel text to nothing
  self.artistNameLabel.text = nil;
}

@end
