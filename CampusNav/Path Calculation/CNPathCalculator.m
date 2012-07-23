//
//  CNPathCalculator.m
//  CampusNav
//
//  Created by Greg Wang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CNPathCalculator.h"
#import "GGSystem.h"

@interface CNPathCalculator ()

@property (nonatomic, strong) GGPOI *source;
@property (nonatomic, strong) GGPOI *destination;

@end

@implementation CNPathCalculator

#pragma mark - Getter & Setter
@synthesize source = _source;
@synthesize destination = _destination;

#pragma mark - Constructor
- (CNPathCalculator *)initFromPOI:(GGPOI *)source toPOI:(GGPOI *)destination
{
	self = [super init];
	if (self != nil) {
		self.source = source;
		self.destination = destination;
	}
	return self;
}

#pragma mark - execution template
- (NSArray *)executeCalculation
{
	NSDictionary *result;
	[self getData];
	[self insertSource:self.source andDestination:self.destination];
	result = [self calculatePath];
	return [self parseCalculationResult:result];
}

#pragma mark - common algorithm
// Return the previous of every vertices
+ (NSDictionary *)dijkstraWithGraph:(GGGraph *)graph 
						 fromSource:(GGPoint *)source 
					  toDestination:(GGPoint *)destination
{
	NSMutableSet *pIds = [NSMutableSet setWithArray:[graph.pointToEdges allKeys]];
	NSMutableDictionary *distances = [NSMutableDictionary dictionaryWithCapacity:[pIds count]];
	NSMutableDictionary *previous = [NSMutableDictionary dictionaryWithCapacity:[pIds count]];
	
	// Distance from source to source
	[distances setObject:[NSNumber numberWithInteger:0] forKey:source.pId];
	
	while ([pIds count] > 0) {
		// Find the vertex with smallest distance in pIds
		NSNumber *uDistance = nil;
		NSNumber *uId = nil;
		for (NSNumber *pId in pIds) {
			NSNumber *distance = [distances objectForKey:pId];
			if (distance != nil && (uDistance == nil || 
				 [distance integerValue] < [uDistance integerValue])) {
				uDistance = distance;
				uId = pId;
			}
		}
		
		// If cannot found `u`, break
		if (uId == nil) {
			break;
		}
		
		// If `u` is destination, break
		if ([uId isEqualToNumber:destination.pId]) {
			break;
		}
		
		// Remove u from pIds
		[pIds removeObject:uId];
		NSLog(@"pId %@ removed", uId);
		
		// 
		NSSet *edges = [graph.pointToEdges objectForKey:uId];
		for (GGEdge *edge in edges) {
			// Find the neighbour
			NSNumber *vId;
			if ([edge.vertexA.pId isEqualToNumber:uId] == NO) {
				vId = edge.vertexA.pId;
			}
			else {
				vId = edge.vertexB.pId;
			}
			
			// If neighbour has been removed from pIds, skip
			if ([pIds containsObject:vId] == NO) {
				NSLog(@"Skiping pId %@, while Q has %d objects", vId, [pIds count]);
				continue;
			}
			
			// Calculate the alternative distance and replace if is smaller
			NSInteger alterDistance = [uDistance integerValue] + edge.weight;
			NSNumber *vDistance = [distances objectForKey:vId];
			if (vDistance == nil || alterDistance < [vDistance integerValue]) {
				[distances setObject:[NSNumber numberWithInteger:alterDistance] forKey:vId];
				[previous setObject:uId forKey:vId];
				NSLog(@"Setting point %@, previous to %@, distance to %d", vId, uId, alterDistance);
			}
		}
	}
	
	return previous;
}

#pragma mark - abstract methods

- (void)getData
{
	return;
}

- (void)insertSource:(GGPOI *)source andDestination:(GGPOI *)destination
{
	return;
}

- (NSDictionary *)calculatePath
{
	return nil;
}

- (NSArray *)parseCalculationResult:(NSDictionary *)result
{
	return nil;
}

@end
