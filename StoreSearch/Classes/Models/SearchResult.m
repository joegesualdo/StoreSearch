//
//  SearchResult.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

// simply compares the name of one SearchResult object to the name of another using NSString’s localizedStandardCompare: method.
- (NSComparisonResult)compareName:(SearchResult *)other {
    return [self.name localizedStandardCompare:other.name];
}

//  The value of kind comes straight from the server and it is more of an internal name than something you’d want to show directly to the user.
// This helper lets us change the name for kind
- (NSString *)kindForDisplay
{
  if ([self.kind isEqualToString:@"album"]) {
    return @"Album";
  } else if ([self.kind isEqualToString:@"audiobook"]) {
    return @"Audio Book";
  } else if ([self.kind isEqualToString:@"book"]) {
    return @"Book";
  } else if ([self.kind isEqualToString:@"ebook"]) {
    return @"E-Book";
  } else if ([self.kind isEqualToString:@"feature-movie"]) {
    return @"Movie";
  } else if ([self.kind isEqualToString:@"music-video"]) {
    return @"Music Video";
  } else if ([self.kind isEqualToString:@"podcast"]) {
    return @"Podcast";
  } else if ([self.kind isEqualToString:@"software"]) {
    return @"App";
  } else if ([self.kind isEqualToString:@"song"]) {
    return @"Song";
  } else if ([self.kind isEqualToString:@"tv-episode"]) {
    return @"TV Episode";
  } else {
    return self.kind;
  }
}
@end
