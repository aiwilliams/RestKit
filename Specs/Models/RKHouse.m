//
//  RKHouse.m
//  RestKit
//
//  Created by Jeremy Ellison on 1/14/10.
//  Copyright 2010 Two Toasters. All rights reserved.
//

#import "RKHouse.h"


@implementation RKHouse

@dynamic city;
@dynamic createdAt;
@dynamic ownerId;
@dynamic railsID;
@dynamic state;
@dynamic street;
@dynamic updatedAt;
@dynamic zip;

@dynamic residents;

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
          @"city", @"city",
          @"state", @"state",
          @"street", @"street",
          @"zip", @"zip",
          @"createdAt", @"created-at",
          @"updatedAt", @"updated-at",
          @"railsID", @"id",
          nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
  return [NSDictionary dictionaryWithObjectsAndKeys:
          @"residents", @"residents",
          nil];
}

+ (NSString*)primaryKeyProperty {
	return @"railsID";
}

+ (NSArray*)relationshipsToSerialize {
  return [NSArray arrayWithObject:@"residents"];
}

@end
