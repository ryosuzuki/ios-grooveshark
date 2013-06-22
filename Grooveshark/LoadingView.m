//
//  LoadingView.m
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/22/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.frame = CGRectMake(0, 0, 50, 50);
        indicator.center = self.center;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self addSubview:indicator];
    [indicator startAnimating];
}

@end
