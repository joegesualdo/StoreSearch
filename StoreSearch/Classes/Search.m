//
//  Search.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/13/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>

// This defines a so-called global variable. It sits outside any class or method. It works just like any other variable, except that you can use it from anywhere and it keeps its value until the application ends. However, this is not a regular global variable. The keyword static restricts its use to just this one source file. Thanks to static, you cannot use this queue variable anywhere outside Search.m.
// staic here means the visibility of this declaration is limited to just this source file. You’ve also seen static variables inside of methods before, but that’s a different kind of static. Exactly what the static keyword does depends on where it is being used, inside or outside of a method.
static NSOperationQueue *queue = nil;

@interface Search ()

//we declare this readwrite because in .h we declared it readonly because we don't want the public to be able to edit. So here we redefine it so we can edit it.
@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;

@end

@implementation Search

// What is the initialize method?
// You can think of initialize as the init method for the entire class, rather than for a specific instance of that class. If this makes your head spin, then just remember that initialize is performed before anything else.
// this is where youshould you initialize the queue variable You only want to do it just once, the very first time it is used. That sounds like a candidate for lazy loading, which will work, but I want to show you another method here.
+ (void)initialize {
  if (self == [Search class]) {
    queue = [[NSOperationQueue alloc] init];
  }
}

- (void)dealloc {
  NSLog(@"dealloc %@", self);
}

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block
{
  if ([text length] > 0) {
    [queue cancelAllOperations];
    self.isLoading = YES;
    self.searchResults = [NSMutableArray arrayWithCapacity:10];
    NSURL *url = [self urlWithSearchText:text category:category];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *
                                                   operation,
                                               id responseObject) {
        [self parseDictionary:responseObject];
        [self.searchResults sortUsingSelector:@selector(compareName:)];
        self.isLoading = NO;
        block(YES);
        NSLog(@"Success!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
          self.isLoading = NO;
          block(NO);
          NSLog(@"Failure!");
        }
    }];
    [queue addOperation:operation];
  }
}

- (NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category
{
  NSString *categoryName;
    
  // This first turns the category index from a number into a string. (Note that the category index is passed to the method as a new parameter.)
  switch (category) {
    // For the first tab  of the segmented control -- "ALL"
    case 0:
      categoryName = @"";
      break;
    // For the second tab  of the segmented control -- "Music"
    case 1:
      categoryName = @"musicTrack";
      break;
    // For the third tab  of the segmented control -- "Software"
    case 2:
      categoryName = @"software";
      break;
    // For the fourth tab  of the segmented control -- "E-books"
    case 3:
      categoryName = @"ebook";
      break;
  }
  //  A space is not a valid character in a URL. Many other characters aren’t valid either (such as the < or > signs) and therefore must be escaped. Another term for this is URL encoding. A space, for example, can be encoded as the + sign (you did that earlier when you typed the URL into the web browser) or as the character sequence %20.
  // Fortunately, NSString can do this encoding already,
    // stringbyAddingPercentEscapesUsingEcoding method escaped all the spaces by putting %20
  NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlString = [NSString
      stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, categoryName];
  // This creates a url object by passing it the url string
  NSURL *url = [NSURL URLWithString:urlString];
  // retuns the url obect
  return url;
}

// method goes through the top-level NSDictionary and looks at each search result in turn. If it’s a type of product the app supports, then it creates a SearchResult object for that product and adds it to the searchResults array.
- (void)parseDictionary:(NSDictionary *)dictionary {
  // makes sure the dictionary contains a key named results that contains an NSArray.
  NSArray *array = dictionary[@"results"];
  if (array == nil) {
    NSLog(@"Expected 'results' array");
    return;
  }
  // look at each of the array’s elements in turn. Remember that each of the elements from the array is another NSDictionary. For each of these dictionaries, you print out the value of its wrapperType and kind fields.
  for (NSDictionary *resultDict in array) {
    SearchResult *searchResult;
    NSString *wrapperType = resultDict[@"wrapperType"];
    NSString *kind = resultDict[@"kind"];
    if ([wrapperType isEqualToString:@"track"]) {
      // we created the parseTrack method below
      searchResult = [self parseTrack:resultDict];
    } else if ([wrapperType isEqualToString:@"audiobook"]) {
      searchResult = [self parseAudioBook:resultDict];
    } else if ([wrapperType isEqualToString:@"software"]) {
      searchResult = [self parseSoftware:resultDict];
    // For some reason, e-books do not have a wrapperType field, so in order to determine whether something is an e-book you have to look at the kind field instead.
    } else if ([kind isEqualToString:@"ebook"]) {
      searchResult = [self parseEBook:resultDict];
    }
    if (searchResult != nil) {
      [self.searchResults addObject:searchResult];
    }
  }
}

// You first allocate a new SearchResult object and then get the values out of the dictionary and put them in the SearchResult’s properties.
- (SearchResult *)parseTrack:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"trackPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}

- (SearchResult *)parseAudioBook:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"collectionName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"collectionViewUrl"];
  // Audio books don’t have a “kind” field, so you have to set the kind property to @"audiobook" yourself.
  searchResult.kind = @"audiobook";
  searchResult.price = dictionary[@"collectionPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}
- (SearchResult *)parseSoftware:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}
- (SearchResult *)parseEBook:(NSDictionary *)dictionary {
  SearchResult *searchResult = [[SearchResult alloc] init];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  // E-books don’t have a “primaryGenreName” field, but an array of genres. You use the componentsJoinedByString method from NSArray to glue these genre names into a single string, separated by commas.
  searchResult.genre =
      [(NSArray *)dictionary[@"genres"] componentsJoinedByString:@", "];
  return searchResult;
}

@end
