//
//  IRDataManager.m
//  IrishRailRT
//
//  Created by Florence Jeulin on 10/09/13.
//  Copyright (c) 2013 Dauran SARL. All rights reserved.
//

#import "IRDataManager.h"
#import "objStationData.h"
#import "objTrainMovements.h"

@implementation IRDataManager

@synthesize myParser, myParser2, trainDirection, trainCode;
@synthesize allTrainDataFirst, allTrainDataSd;

static IRDataManager *sharedData_loader = nil;

+ (IRDataManager*) sharedManagerData_Loader {
    if(sharedData_loader == nil) {
        sharedData_loader = [[IRDataManager alloc] init];
    }
    return sharedData_loader;
}

- (id) init {
    if (self = [super init]) {
        self.myParser = [[XMLToObjectParser alloc] init];
        self.myParser2 = [[XMLToObjectParser alloc] init];
        self.trainCode = nil;
        self.trainDirection = nil;
    }
    
    return self;
}

-(void)loadTrainCode_forStationCode:(NSString*)stationCode {
    //initialize with no error
    lcErr = 0;
    NSError *parseError = nil;
    NSString *urlString = [NSString stringWithFormat:@"http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=%@",stationCode];
    //NSLog(@"loadTRainCode stationCode = %@", stationCode);
    //NSLog(@"loadTrainCode URL=%@", urlString);
    NSURL *xmlURL = [NSURL URLWithString:urlString];
    
    [self.myParser parseXMLAtURL:xmlURL toObject:@"objStationData" parseError:&parseError];
    
    if(parseError != nil) {
        self.error = parseError;
        self.trainCode = nil;
        lcErr = -1;
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_ERROR object:nil];
        
    } else {
    
        self.allTrainDataSd = [NSMutableArray array];
        self.allTrainDataFirst = [NSMutableArray array];
        
        if([[self.myParser items] count] != 0) {
            //get the first train in the station with stationCode with the good direction
            [self readParseDataWithCode:stationCode];
            
            //as there is one stop in Bray, we always have to load data for Bray
            urlString = @"http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=BRAY";
            xmlURL = [NSURL URLWithString:urlString];
            
            XMLToObjectParser *aParser = [[XMLToObjectParser alloc] init];
            [aParser parseXMLAtURL:xmlURL toObject:@"objStationData" parseError:&parseError];
            
            if(parseError != nil) {
                self.error = parseError;
                self.trainCode = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:DATA_ERROR object:nil];
                
            } else {
                
                if([[aParser items] count] != 0) {
                    
                    [self readParseDataWithCode:stationCode inParser:aParser];
                    
                } else {
                    //No train in the next 90 minutes for this station
                    [[NSNotificationCenter defaultCenter] postNotificationName:NO_TRAIN_90 object:nil];
                    
                }
                
            }
            
        } else {
            //No train in the next 90 minutes for this station
            [[NSNotificationCenter defaultCenter] postNotificationName:NO_TRAIN_90 object:nil];
            lcErr = -1;
        }
        
    }
    if (lcErr == 0) {
        
        if([allTrainDataFirst count] != 0 && [allTrainDataSd count] != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TRAIN_CODE_READY object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NO_TRAIN_90 object:nil];
            
            NSLog(@"**** NO TRAIN");
            
            NSLog(@"FIRST PART ** count =%d", [allTrainDataFirst count]);
            if([allTrainDataFirst count] != 0) {
                for(int i=0; i<[allTrainDataFirst count]; i++) {
                    NSLog(@"TrainCode =<%@> Location Code = %@",[(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] TrainCode],[(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] LocationCode]);
                    NSLog(@"----> Scheduled Departure = %@", [(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] ScheduledDeparture]);
                    NSLog(@"----> EXpected Departure = %@", [(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] ExpectedDeparture]);
                    NSLog(@"----> Scheduled Arrival = %@", [(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] ScheduledArrival]);
                    NSLog(@"----> Expected Arrival = %@", [(objTrainMovements*)[allTrainDataFirst objectAtIndex:i] ExpectedArrival]);
                    
                }
                
            }
            
            NSLog(@"Sec PART ** count = %d",[allTrainDataSd count]);
            if([allTrainDataSd count] != 0) {
                for(int i=0; i<[allTrainDataSd count]; i++) {
                    NSLog(@"TrainCode =<%@> Location Code = %@",[(objTrainMovements*)[allTrainDataSd objectAtIndex:i] TrainCode],[(objTrainMovements*)[allTrainDataSd objectAtIndex:i] LocationCode]);
                    NSLog(@"----> Scheduled Departure = %@", [(objTrainMovements*)[allTrainDataSd objectAtIndex:i] ScheduledDeparture]);
                    NSLog(@"----> EXpected Departure = %@", [(objTrainMovements*)[allTrainDataSd objectAtIndex:i] ExpectedDeparture]);
                    NSLog(@"----> Scheduled Arrival = %@", [(objTrainMovements*)[allTrainDataSd objectAtIndex:i] ScheduledArrival]);
                    NSLog(@"----> Expected Arrival = %@", [(objTrainMovements*)[allTrainDataSd objectAtIndex:i] ExpectedArrival]);
                    
                }
                
            }
        }
    }
    
}

-(void)readParseDataWithCode:(NSString*)stationCode {
    NSLog(@"readParseDataWithCode for stationCode=%@",stationCode);
    for(int i=0; i < [[self.myParser items] count]; i++) {
        NSString *myDirection = [(objStationData *)[[self.myParser items] objectAtIndex:i] Direction];
        
        // 1 - if we are on a Journey from Shankill to Arklow via Bray, Direction must be Southbound for train from Shankill to Bray
        // 2 - if we are on a Journey from Arklow to Shankill via Bray, Direction must be Northbound for train from Arklow to Bray
        
        if ([stationCode isEqualToString:@"SKILL"]) {
            //we are on a Journey from Shankill to Arklow via Bray
            //Direction must be Northbound for train from Shankill to Bray
            if([myDirection isEqualToString:@"Southbound"]) {
                [self loadData_forTrainCode:[(objStationData *)[[self.myParser items] objectAtIndex:i] Traincode] forPart:1];
                break;
            } //else do nothing
        } else if ([stationCode isEqualToString:@"ARKLW"]) {
            //we are on a Journey from Arklow to Shankill via Bray
            //Direction must be Northbound for train from Arklow to Bray
            if([myDirection isEqualToString:@"Northbound"]) {
                [self loadData_forTrainCode:[(objStationData *)[[self.myParser items] objectAtIndex:i] Traincode] forPart:1];
                break;
            }
            
        }
    }
    
}

-(void)readParseDataWithCode:(NSString*)stationCode inParser:(XMLToObjectParser*)localParser {
    
    //parse data for BRAY with StationCode = code of station origin
    NSLog(@"****** BRAY ***** readParseDataWithCode for stationCode=%@ in aParser",stationCode);
    
    for(int i=0; i < [[localParser items] count]; i++) {
        NSString *myDirection = [NSString stringWithString:[(objStationData *)[[localParser items] objectAtIndex:i] Direction]];
        NSString *myDestination = [NSString stringWithString:[(objStationData *)[[localParser items] objectAtIndex:i] Destination]];
        NSString *myTraintype = [NSString stringWithString:[(objStationData *)[[localParser items] objectAtIndex:i] Traintype]];
        
        if ([stationCode isEqualToString:@"SKILL"]) {
            //we are on a Journey from Shankill to Arklow via Bray
            //so train from Bray to Arklow must be direction == southbound and no DART 
            //Direction must be Southbound and not DART
            if([myDirection isEqualToString:@"Southbound"] && ![myDestination isEqualToString:@"Bray"] && ![myTraintype isEqualToString:@"DART"]) {
                //load data for this train code
                [self loadData_forTrainCode:[(objStationData *)[[localParser items] objectAtIndex:i] Traincode] forPart:2];
                //break;
            }
            
        } else if([stationCode isEqualToString:@"ARKLW"]){
            //We are on a journey from Arklow to shankill via Bray
            //so train from Bray to Shankill must be direction == Northbound and DART
            //Direction must be Southbound 
            if([myDirection isEqualToString:@"Northbound"]  && ![myDestination isEqualToString:@"Bray"]  && [myTraintype isEqualToString:@"DART"]) {
                [self loadData_forTrainCode:[(objStationData *)[[localParser items] objectAtIndex:i] Traincode] forPart:2];
                //break;
            }
        }
        
        
        
    }
}


-(void)loadData_forTrainCode:(NSString*)myTrainCode forPart:(int)journeyPart {
    NSError *parseError = nil;
    
    NSString *newTrainCode = nil;
    //there is an extra char at the end of TrainCode
    if([myTrainCode characterAtIndex:[myTrainCode length]-1] == ' ') {
        newTrainCode = [myTrainCode substringToIndex:[myTrainCode length]-1];
    } else {
        newTrainCode = [NSString stringWithString:myTrainCode];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=%@&TrainDate=",newTrainCode];
    NSLog(@"loadData for trainCode = <%@>\n urlString=<%@>", newTrainCode, urlString);
    NSURL *xmlURL = [NSURL URLWithString:urlString];
    
    //NSLog(@"loadData_forTrainCode xmlURL=%@",xmlURL);
    
    [self.myParser2 parseXMLAtURL:xmlURL toObject:@"objTrainMovements" parseError:&parseError];
    
    if(parseError != nil) {
        self.error = parseError;
        self.trainCode = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_ERROR object:nil];
        
    } else {
        if([[self.myParser2 items] count] != 0) {
            
            for(int i=0; i < [[self.myParser2 items] count]; i++) {
                
                //LocationCode
                NSString *myLocCode = [(objTrainMovements *)[[self.myParser2 items] objectAtIndex:i] LocationCode];
                
                
                if([myLocCode isEqualToString:@"SKILL"] || [myLocCode isEqualToString:@"BRAY"]) {
                    if(journeyPart == 1) {
                        [self.allTrainDataFirst addObject:(objTrainMovements *)[[self.myParser2 items] objectAtIndex:i]];
                    } else {
                        [self.allTrainDataSd addObject:(objTrainMovements *)[[self.myParser2 items] objectAtIndex:i]];
                    }
                } else if([myLocCode isEqualToString:@"ARKLW"] || [myLocCode isEqualToString:@"BRAY"]) {
                    if(journeyPart == 1) {
                        [self.allTrainDataFirst addObject:(objTrainMovements *)[[self.myParser2 items] objectAtIndex:i]];
                    } else {
                        [self.allTrainDataSd addObject:(objTrainMovements *)[[self.myParser2 items] objectAtIndex:i]];
                    }
                }
            }
            
        } else {
            //No train in the next 90 minutes for this station
            [[NSNotificationCenter defaultCenter] postNotificationName:NO_TRAIN_90 object:nil];
        }
    }
    
    
}

@end
