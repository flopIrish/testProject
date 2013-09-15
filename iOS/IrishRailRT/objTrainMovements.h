//
//  objTrainMovements.h
//  IrishRailRT
//

#import <Foundation/Foundation.h>

@interface objTrainMovements : NSObject {
    NSString *TrainCode;
    NSString *LocationCode;
    NSString *ExpectedDeparture;
    NSString *ScheduledDeparture;
    NSString *ExpectedArrival;
    NSString *ScheduledArrival;
}

@property (nonatomic, retain) NSString *TrainCode;
@property (nonatomic, retain) NSString *LocationCode;
@property (nonatomic, retain) NSString *ExpectedDeparture;
@property (nonatomic, retain) NSString *ScheduledDeparture;
@property (nonatomic, retain) NSString *ExpectedArrival;
@property (nonatomic, retain) NSString *ScheduledArrival;



-(id)copyWithZone:(NSZone *)zone;

@end
