//
//  CatapultCurrentAccountLoadingView.m
//  Catapult
//
//  Created by Aziz Light on 4/30/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultCurrentAccountLoadingView.h"

@implementation CatapultCurrentAccountLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.706];
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 96, 96) cornerRadius: 15];
    [color setFill];
    [roundedRectanglePath fill];
}

@end
