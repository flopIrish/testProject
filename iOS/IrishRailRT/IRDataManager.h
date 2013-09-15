//
//  IRDataManager.h
//  IrishRailRT
//
//  Created by Florence Jeulin on 10/09/13.
//  Copyright (c) 2013 Dauran SARL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLToObjectParser.h"
#import "IrishRailRT.h"

@interface IRDataManager : NSObject {
    XMLToObjectParser *myParser;
    XMLToObjectParser *myParser2;
    NSError * _error;
    int lcErr; //to handle error in this object
    
    NSMutableArray *allTrainDataFirst; //from departure to Bray
    NSMutableArray *allTrainDataSd; //from Bray to end
    NSString *trainCode;
    NSString *trainDirection;
}

@property (nonatomic, retain) NSError * error;
@property (nonatomic, retain) XMLToObjectParser *myParser;
@property (nonatomic, retain) XMLToObjectParser *myParser2;
@property (nonatomic, retain) NSMutableArray *allTrainCode;
@property (nonatomic, retain) NSString *trainCode;
@property (nonatomic, retain) NSString *trainDirection;
@property (nonatomic, retain) NSMutableArray *allTrainDataFirst; //from departure to Bray
@property (nonatomic, retain) NSMutableArray *allTrainDataSd; //from Bray to end

+ (IRDataManager*) sharedManagerData_Loader;
-(void)loadTrainCode_forStationCode:(NSString*)stationCode;
-(void)loadData_forTrainCode:(NSString*)trainCode forPart:(int)journeyPart;

@end
