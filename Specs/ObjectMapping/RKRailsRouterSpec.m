//
//  RKRailsRouterSpec.m
//  RestKit
//
//  Created by Blake Watters on 10/19/10.
//  Copyright 2010 Two Toasters. All rights reserved.
//

#import "RKSpecEnvironment.h"
#import "RKObjectManager.h"
#import "RKManagedObjectStore.h"
#import "RKRailsRouter.h"
#import "RKHuman.h"
#import "RKCat.h"
#import "RKHouse.h"
#import "RKResident.h"

@interface RKRailsRouterSpecUnregisteredModel : RKManagedObject {
}
@end
@implementation RKRailsRouterSpecUnregisteredModel
@end



@interface RKRailsRouterSpec : NSObject <UISpec> {
}

@property (nonatomic, retain) RKRailsRouter* router;
@property (nonatomic, retain) RKHuman* human;

@end

@implementation RKRailsRouterSpec

@synthesize router;
@synthesize human;

- (void)beforeAll {
	RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:@"http://localhost:4567"];
	objectManager.objectStore = [[RKManagedObjectStore alloc] initWithStoreFilename:@"RestKitSpecs.sqlite"];
}

- (void)before {
  self.router = [[[RKRailsRouter alloc] init] autorelease];
  [router setModelName:@"Human" forClass:[RKHuman class]];
  
  self.human = [[RKHuman object] autorelease];
	human.name = @"Blake";
	human.age = [NSNumber numberWithInt:27];
	human.railsID = [NSNumber numberWithInt:31337];
}

- (void)itShouldRaiseErrorWhenAskedToRouteAnUnregisteredModel {
	NSException* exception = nil;
	@try {
		[router serializationForObject:[RKRailsRouterSpecUnregisteredModel object] method:RKRequestMethodPOST];
	}
	@catch (NSException * e) {
		exception = e;
	}
	[expectThat(exception) shouldNot:be(nil)];
}

- (void)itShouldAnswerRKRequestSerializable
{
	id serialization = [router serializationForObject:human method:RKRequestMethodPOST];
	[expectThat(serialization) shouldNot:be(nil)];
  expectThat([serialization conformsToProtocol:@protocol(RKRequestSerializable)]);
}

- (void)itShouldIncludeModelNameWithAttributes
{
	NSObject<RKRequestSerializable>* serialization = [router serializationForObject:human method:RKRequestMethodPOST];
	[expectThat([serialization valueForKey:@"human[name]"]) should:be(@"Blake")];
	[expectThat([serialization valueForKey:@"human[age]"]) should:be(27)];
}

- (void)itShouldNotIncludeEntityIdWhichCannotBeMassAssigned
{
	NSObject<RKRequestSerializable>* serialization = [router serializationForObject:human method:RKRequestMethodPOST];
	[expectThat([serialization valueForKey:@"id"]) should:be(nil)];
}

- (void)itShouldIncludeHasManyAssociationAttributesAsArrayOfDictionaries
{
  RKCat* cat = [[RKCat object] autorelease];
  cat.name = @"Zeus";
  cat.birthYear = [NSNumber numberWithInt:1982];
  [human addCatsObject:cat];
  
  NSDictionary* serialization = (NSDictionary*) [router serializationForObject:human method:RKRequestMethodPOST];
  NSArray* serializedCats = [serialization objectForKey:@"human[cats_attributes]"];
  NSDictionary* catAttributes = [serializedCats objectAtIndex:0];
  [expectThat([catAttributes objectForKey:@"name"]) should:be(@"Zeus")];
  [expectThat([catAttributes objectForKey:@"birth_year"]) should:be(1982)];
}

- (void)itShouldIncludeHasOneAssociationAttributesAsDictionary
{
  human.house = [[RKHouse object] autorelease];
  human.house.zip = @"78212";
  
  NSDictionary* serialization = (NSDictionary*) [router serializationForObject:human method:RKRequestMethodPOST];
  NSDictionary* houseAttributes = (NSDictionary*) [serialization objectForKey:@"human[house_attributes]"];
  [expectThat([houseAttributes objectForKey:@"zip"]) should:be(@"78212")];
}

- (void)itShouldNotIncludeAssociationEntityIdWhenNewRecord
{
  RKCat* cat = [[RKCat object] autorelease];
  [human addCatsObject:cat];
  
  NSDictionary* serialization = (NSDictionary*) [router serializationForObject:human method:RKRequestMethodPOST];
  NSArray* serializedCats = [serialization objectForKey:@"human[cats_attributes]"];
  NSDictionary* catAttributes = [serializedCats objectAtIndex:0];
  [expectThat([catAttributes objectForKey:@"id"]) should:be(nil)];
}

- (void)itShouldIncludeAssociationEntityIdWhenExistingRecord
{
  RKCat* cat = [[RKCat object] autorelease];
  cat.railsID = [NSNumber numberWithInt:1];
  [human addCatsObject:cat];
  
  NSDictionary* serialization = (NSDictionary*) [router serializationForObject:human method:RKRequestMethodPOST];
  NSArray* serializedCats = [serialization objectForKey:@"human[cats_attributes]"];
  NSDictionary* catAttributes = [serializedCats objectAtIndex:0];
  [expectThat([catAttributes objectForKey:@"id"]) should:be(1)];
}

- (void)itShouldIncludeHasMayAttributesThroughHasOneAssociations
{
  human.house = [[RKHouse object] autorelease];
  
  RKResident* resident1 = [[RKResident object] autorelease];
  resident1.residableId = [NSNumber numberWithInt:123];
  resident1.railsID = [NSNumber numberWithInt:876];
  [human.house addResidentsObject:resident1];
  
  RKResident* resident2 = [[RKResident object] autorelease];
  resident2.residableId = [NSNumber numberWithInt:234];
  [human.house addResidentsObject:resident2];
  
  NSDictionary* serialization = (NSDictionary*) [router serializationForObject:human method:RKRequestMethodPOST];
  NSDictionary* houseAttributes = (NSDictionary*) [serialization objectForKey:@"human[house_attributes]"];
  
  NSArray* serializedResidents = [houseAttributes objectForKey:@"residents_attributes"];
  [expectThat(serializedResidents) shouldNot:be(nil)];
  [expectThat([serializedResidents count]) should:be(2)];
  
  NSDictionary* resident1Attributes = [serializedResidents objectAtIndex:0];
  [expectThat([resident1Attributes objectForKey:@"residable_id"]) should:be(123)];
  [expectThat([resident1Attributes objectForKey:@"id"]) should:be(876)];
  
  NSDictionary* resident2Attributes = [serializedResidents objectAtIndex:1];
  [expectThat([resident2Attributes objectForKey:@"residable_id"]) should:be(234)];
  [expectThat([resident2Attributes objectForKey:@"id"]) should:be(nil)];
}

@end
