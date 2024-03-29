//
//  objTrainMovements.m
//  IrishRailRT
//

#import "objTrainMovements.h"

@implementation objTrainMovements

@synthesize TrainCode, LocationCode;
@synthesize ExpectedDeparture, ScheduledDeparture, ExpectedArrival, ScheduledArrival;

-(id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    objTrainMovements *newObjTM = [[objTrainMovements alloc] init];
    
    [newObjTM setTrainCode:TrainCode];
    [newObjTM setLocationCode:LocationCode];
    [newObjTM setExpectedDeparture:ExpectedDeparture];
    [newObjTM setScheduledDeparture:ScheduledDeparture];
    [newObjTM setExpectedArrival:ExpectedArrival];
    [newObjTM setScheduledArrival:ScheduledArrival];
    
    return newObjTM;
}


@end
