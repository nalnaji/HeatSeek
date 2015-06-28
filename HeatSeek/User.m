//
//  User.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize fullname = _fullname;
@synthesize fbid = _fbid;

- (id)initWithFullname:(NSString *)theFullname initWithFBID:(NSString *)theFBID {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        fullname = [theFullname copy];
        fbid = [theFBID copy];
        _fullname = [theFullname copy];
        _fbid = [theFBID copy];
    }
    return self;
}

@end

