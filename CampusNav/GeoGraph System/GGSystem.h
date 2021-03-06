//
//  GGSystem.h
//  CampusNav
//
//  Created by Greg Wang on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Include all interface required for upper layer usage
 * Since this is a fecade interface
 */
#import "GGBuilding.h"
#import "GGFloorPlan.h"
#import "GGPoint.h"
#import "GGElement.h"
#import "GGPOI.h"
#import "GGEdge.h"
#import "GGGraph.h"

@interface GGSystem : NSObject

+ (GGSystem *)sharedGeoGraphSystem;

// Data fetching methods
// Buildings
- (NSArray *)buildingsInCampus:(NSString *)campus;

// FloorPlans
- (NSArray *)floorPlansOfCampus:(NSString *)campus;
- (NSArray *)floorPlansOfBuilding:(GGBuilding *)building;

// POIs
- (NSArray *)poisInBuilding:(GGBuilding *)building;
- (NSArray *)poisOnFloorPlan:(GGFloorPlan *)floorPlan;

// Graph Generation
- (GGGraph *)graphOfFloorPlan:(GGFloorPlan *)floorPlan;

@end
