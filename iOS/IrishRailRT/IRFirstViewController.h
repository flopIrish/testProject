//
//  IRFirstViewController.h
//  IrishRailRT
//
//  Created by Florence Jeulin on 10/09/13.
//  Copyright (c) 2013 Dauran SARL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRFirstViewController : UIViewController {
    UISegmentedControl *fromSgtCtrl;
    UISegmentedControl *toSgtCtrl;
    
    UILabel * infoTrain;
    
    UILabel * startStationName; //the name of the station on start of journey
    UILabel * departStartTime; // time of departue
    UILabel * brayStationName_E; //end
    UILabel * brayStationName_S; //start
    UILabel * brayStopTime; // time of arrival in Bray
    UILabel * brayStartTime; //time of departure from Bray
    UILabel * stopStationName; //the name of the station on end of journey
    UILabel * stopEndTime; //time of arrival in final station
    NSArray *listOfStationName;
}

@property (nonatomic, retain) NSArray *listOfStationName;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fromSgtCtrl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *toSgtCtrl;
@property (nonatomic, retain) IBOutlet UILabel *infoTrain;
@property (nonatomic, retain) IBOutlet UILabel * startStationName; //the name of the station on start of journey
@property (nonatomic, retain) IBOutlet UILabel * departStartTime; // time of departue
@property (nonatomic, retain) IBOutlet UILabel * brayStationName_E;
@property (nonatomic, retain) IBOutlet UILabel * brayStationName_S;
@property (nonatomic, retain) IBOutlet UILabel * brayStopTime; // time of arrival in Bray
@property (nonatomic, retain) IBOutlet UILabel * brayStartTime; //time of departure from Bray
@property (nonatomic, retain) IBOutlet UILabel * stopStationName; //the name of the station on end of journey
@property (nonatomic, retain) IBOutlet UILabel * stopEndTime; //time of arrival in final station

@end
