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
@end
