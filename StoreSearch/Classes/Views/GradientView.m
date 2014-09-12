//
//  GradientView.m
//  StoreSearch
//
//  Created by Joe Gesualdo on 9/12/14.
//  Copyright (c) 2014 Joe Gesualdo. All rights reserved.
//

// What is this view?
// This will be a very simple view. It simply draws a black circular gradient that goes from a mostly opaque in the corners to mostly transparent in the center. It’s a similar dimmed background that you used to see behind UIAlertViews on iOS 6 and earlier. Placed on a white background, it looks like this:

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      // set the background color to fully transparent.
      self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// draw the gradient on top of that transparent background, so that it blends with whatever is below.
// The drawing code uses the Core Graphics framework (also known as Quartz 2D). It may look a little scary but this is plain old C code.
- (void)drawRect:(CGRect)rect { // 1
    // First you create two C-style arrays that contain the “color stops” for the gradient. The first color (0.0, 0.0, 0.0, 0.3) is a black color that is mostly transparent. It sits at position 0.0 in the gradient, which represents the center of the screen because you’ll be drawing a circular gradient.
    // The second color (0.0, 0.0, 0.0, 0.7) is also black but much less transparent and sits at location 1.0, which represents the circumference of the gradient’s circle. (Remember that in UIKit and also in Core Graphics, colors and opacity values don’t go from 0 to 255 but from 0.0 to 1.0.)
  const CGFloat components[8] = {0.0f, 0.0f, 0.0f, 0.3f,
                                 0.0f, 0.0f, 0.0f, 0.7f};
  const CGFloat locations[2] = {0.0f, 1.0f}; // 2
  // With those color stops you can create the gradient. This gives you a new CGGradientRef object. This is not an object in the sense of Objective-C, so you cannot send it messages by doing [gradient methodName]. But it’s still some kind of data structure that lives in memory, and the gradient variable points to it.
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient =
      CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGColorSpaceRelease(space); // 3
    // Now that you have the gradient object, you have to figure out how big you need to draw it. The CGRectGetMidX() and CGRectGetMidY()functions return the center point of a rectangle. That rectangle is given by self.bounds, which tells you how big the view is.
    // If I can avoid it, I prefer not to hard-code any dimensions such as “320 by 480 points”. By asking self.bounds, you can use this view anywhere you want to, no matter how big a space it should fill (you could reuse it without problems on an iPad, for example, whose screen is a lot bigger!).
    // The point variable contains the coordinates for the center point of the view and radius contains the larger of the x and y values. MAX() is a handy macro that you can use to determine which of two values is the biggest.

  CGFloat x = CGRectGetMidX(self.bounds);
  CGFloat y = CGRectGetMidY(self.bounds);
  CGPoint point = CGPointMake(x, y);
  CGFloat radius = MAX(x, y);
  // 4
  // With all those preliminaries done, you can finally draw the thing. Core Graphics drawing always takes places in a so-called context. We’re not going to worry about exactly what that is, just know that you need to obtain a reference to the current context and then you can do your drawing. The CGContextDrawRadialGradient() function finally draws the gradient according to your specifications.
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextDrawRadialGradient(context, gradient, point, 0, point, radius,
                              kCGGradientDrawsAfterEndLocation);
  // When you’re done, you need to release the gradient object (notice that you also released the CGColorSpaceRef object earlier).
  // that Automatic Reference Counting only works on Objective-C code, not on plain old C code. And that’s exactly what Core Graphics is, plain old C code. Any time you create a new object with Core Graphics, such as the CGGradientRef object you made with CGGradientCreateWithColorComponents(), you also have to release it once you’re done with it.
  CGGradientRelease(gradient);
}

//  verify that the gradient view is properly deallocated:
- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end
