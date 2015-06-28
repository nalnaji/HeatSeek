//
//  User.h
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
NSString *fullname;
NSString *fbid;
}

@property(retain, nonatomic) NSString * fullname;
@property(retain, nonatomic) NSString * fbid;

-(void) setFullname:(NSString *) theFullname;
-(void) setFBID:(NSString *) theFBID;
- (id)initWithFullname:(NSString *)theFullname initWithFBID:(NSString *)theFBID;

@end