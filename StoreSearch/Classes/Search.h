//
//  Search.h
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/13/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import <Foundation/Foundation.h>

// Here you’re declaring a type for your own block, named SearchBlock. This is a block that returns no value (void) and takes one parameter, a BOOL named success.
// What is the typedef?
// It allows you to create a symbolic name for a datatype, in order to save you some typing and to make the code more readable.
// From now on you can use the name SearchBlock to refer to a block that takes one BOOL parameter and returns no value.
typedef void (^SearchBlock)(BOOL success);

@interface Search : NSObject

@property (nonatomic, assign) BOOL isLoading;
// “readonly”. That means users of this class can only read what is inside the searchResults array but they cannot replace the searchResults array with another one (why would they?).
// We create another search results property in the .m file so we can edit it
// do want full control over the searchResults array and therefore you re-declare it as “readwrite” in the class extension.
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;

@end
