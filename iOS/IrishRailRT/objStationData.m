//
//  objStationData.m
//  IrishRailRT
//

#import "objStationData.h"

@implementation objStationData

@synthesize Traincode, Direction, Destination, Expdepart, Schdepart, Traintype;

-(id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    objStationData *newobjSD = [[objStationData alloc] init];
    
    [newobjSD setDirection:Direction];
    [newobjSD setTraincode:Traincode];
    [newobjSD setDestination:Destination];
    [newobjSD setTraintype:Traintype];
    [newobjSD setExpdepart:Expdepart];
    [newobjSD setSchdepart:Schdepart];
    
    return newobjSD;
}

@end
