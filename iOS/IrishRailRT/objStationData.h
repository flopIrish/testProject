//
//  objStationData.h
//  IrishRailRT
//

#import <Foundation/Foundation.h>

@interface objStationData : NSObject {
    NSString *Traincode;
    NSString *Direction;
    NSString *Destination;
    NSString *Traintype;
    NSString *Expdepart;
    NSString *Schdepart;
}

@property (nonatomic, retain) NSString *Traincode;
@property (nonatomic, retain) NSString *Direction;
@property (nonatomic, retain) NSString *Destination;
@property (nonatomic, retain) NSString *Traintype;
@property (nonatomic, retain) NSString *Expdepart;
@property (nonatomic, retain) NSString *Schdepart;


@end
