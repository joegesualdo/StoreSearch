//
//  SearchResult.h
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/10/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

// Why do we use copy instead of weak or strong?
// The properties are marked copy rather than strong. When you assign a value to such a property, it will first make a copy of the object and then treat that as a strong reference. It is a good idea to use copy for classes such as NSString and NSArray that have a mutable subclass (NSMutableString, NSMutableArray). For more info, see the section “Copy and assign properties” in the MyLocations tutorial.
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;

// You’re not including everything that the iTunes store returns, only the fields that you’re interested in.
@property(nonatomic, copy) NSString *artworkURL60;
@property(nonatomic, copy) NSString *artworkURL100;
@property(nonatomic, copy) NSString *storeURL;
@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString *currency;
@property(nonatomic, copy) NSDecimalNumber *price;
@property(nonatomic, copy) NSString *genre;

- (NSComparisonResult)compareName:(SearchResult *)other;

@end
