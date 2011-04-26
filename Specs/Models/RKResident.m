// 
//  RKResident.m
//  RestKit
//
//  Created by Jeremy Ellison on 1/14/10.
//  Copyright 2010 Two Toasters. All rights reserved.
//

#import "RKResident.h"
#import "RKHouse.h"

@implementation RKResident 

@dynamic residableType;
@dynamic railsID;
@dynamic residableId;
@dynamic houseId;
@dynamic house;

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
          @"residableId", @"residable_id",
          @"railsID", @"id",
          nil];
}

+ (NSString*)primaryKeyProperty {
	return @"railsID";
}

@end
