//
//  IRFirstViewController.m
//  IrishRailRT
//

#import "IRFirstViewController.h"
#import "IRDataManager.h"
#import "objStationData.h"
#import "objTrainMovements.h"


@interface IRFirstViewController ()

@end

@implementation IRFirstViewController

@synthesize fromSgtCtrl, toSgtCtrl, infoTrain, listOfStationName;
@synthesize startStationName,departStartTime ,brayStationName_S, brayStationName_E, brayStopTime, brayStartTime, stopStationName, stopEndTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Journey", @"Journey");
        self.tabBarItem.image = [UIImage imageNamed:@"double_arrow"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.listOfStationName = [NSArray arrayWithObjects:@"Arklow",@"Bray",@"Shankill", nil];
    
    //UISegmentCtrl settings
    NSString * startStation = @"Arklow";
    NSString * endStation = @"Shankill";
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"startStation"] length] != 0
        && [[[NSUserDefaults standardUserDefaults] stringForKey:@"endStation"] length] !=0 ) {
        startStation = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"startStation"]];
        endStation = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"endStation"]];
    }
    
    [self.fromSgtCtrl setTitle:startStation forSegmentAtIndex:0];
    [self.fromSgtCtrl setTitle:endStation forSegmentAtIndex:1];
    
    [self.toSgtCtrl setTitle:startStation forSegmentAtIndex:0];
    [self.toSgtCtrl setTitle:endStation forSegmentAtIndex:1];
    
    [self.fromSgtCtrl addTarget:self action:@selector(fromSgtAction) forControlEvents:UIControlEventValueChanged];
    [self.toSgtCtrl addTarget:self action:@selector(toSgtAction) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(manageNotification:)
                                                 name:TRAIN_CODE_READY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(manageNotification:)
                                                 name:NO_TRAIN_90
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(manageNotification:)
                                                 name:DATA_ERROR
                                               object:nil];
    
    //to set correct journey depending on the time today
    
    NSDate *now = [NSDate date];
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                 fromDate:[NSDate date]];
    [components setHour: 12];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *todayAt12 = [myCalendar dateFromComponents:components];
    if ([now compare:todayAt12] == NSOrderedDescending) {
        NSLog(@"After 12:00 local time, we reverse the journey");
        self.fromSgtCtrl.selectedSegmentIndex = 1;
        self.toSgtCtrl.selectedSegmentIndex = 0;
        [[IRDataManager sharedManagerData_Loader] loadTrainCode_forStationCode:@"SKILL"];
    } else {
        self.fromSgtCtrl.selectedSegmentIndex = 0;
        self.toSgtCtrl.selectedSegmentIndex = 1;
        [[IRDataManager sharedManagerData_Loader] loadTrainCode_forStationCode:@"ARKLW"];
    }
}

-(void)manageNotification:(NSNotification*)myNotification {
    NSString *notifName = [myNotification name];
    
    NSLog(@"manageNotification notif name=%@",notifName);
    
    if([notifName isEqualToString:TRAIN_CODE_READY]) {
        self.infoTrain.text = @"";
        
        [self.startStationName setHidden:NO];
        [self.departStartTime setHidden:NO];
        [self.brayStationName_E setHidden:NO];
        [self.brayStationName_S setHidden:NO];
        [self.brayStopTime setHidden:NO];
        [self.brayStartTime setHidden:NO];
        [self.stopStationName setHidden:NO];
        [self.stopEndTime setHidden:NO];
        [self.infoTrain setHidden:YES];
        
        [self buildTrainInformations];
        
        
    
    } else if([notifName isEqualToString:NO_TRAIN_90]) {
        //there is no train in the station for the next 90 minutes
        [self.infoTrain setHidden:NO];
        
        [self.startStationName setHidden:YES];
        [self.departStartTime setHidden:YES];
        [self.brayStationName_E setHidden:YES];
        [self.brayStationName_S setHidden:YES];
        [self.brayStopTime setHidden:YES];
        [self.brayStartTime setHidden:YES];
        [self.stopStationName setHidden:YES];
        [self.stopEndTime setHidden:YES];
        self.infoTrain.text = NSLocalizedString(@"NoTrain90",@"NoTrain90");

    } else if([notifName isEqualToString:DATA_ERROR]) {
        //there is no train in the station for the next 90 minutes
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DataError",@"DataError")
                                                                        message:NSLocalizedString(@"TryAgain", @"")
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[servicesDisabledAlert show];
        [servicesDisabledAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}

-(void)buildTrainInformations {
    //all train at shankill or Arklow (depending of the time of the day)
    NSArray *allTrain_ft = [NSArray  arrayWithArray:[[IRDataManager sharedManagerData_Loader] allTrainDataFirst]];
    NSArray *allTrain_sd = [NSArray arrayWithArray:[[IRDataManager sharedManagerData_Loader] allTrainDataSd]];
    
    
    // 1 - we have to select trains from Shankill to Bray
    for(int i=0; i<[allTrain_ft count]; i++) {
        NSLog(@"TrainCode =<%@> Location Code = %@",[(objTrainMovements*)[allTrain_ft objectAtIndex:i] TrainCode],[(objTrainMovements*)[allTrain_ft objectAtIndex:i] LocationCode]);
        NSLog(@"----> Scheduled Departure = %@", [(objTrainMovements*)[allTrain_ft objectAtIndex:i] ScheduledDeparture]);
        NSLog(@"----> Expected Departue = %@", [(objTrainMovements*)[allTrain_ft objectAtIndex:i] ExpectedDeparture]);
        NSLog(@"----> Scheduled Arrival = %@", [(objTrainMovements*)[allTrain_ft objectAtIndex:i] ScheduledArrival]);
        NSLog(@"----> Expected Arrival = %@", [(objTrainMovements*)[allTrain_ft objectAtIndex:i] ExpectedArrival]);
        
    }
    
    NSLog(@"***********************************************"); 
    
    // 2 - then Train from Bray to Arklow
    for(int i=0; i<[allTrain_sd count]; i++) {
        NSLog(@"TrainCode =<%@> Location Code = %@",[(objTrainMovements*)[allTrain_sd objectAtIndex:i] TrainCode],[(objTrainMovements*)[allTrain_sd objectAtIndex:i] LocationCode]);
        NSLog(@"----> Scheduled Departure = %@", [(objTrainMovements*)[allTrain_sd objectAtIndex:i] ScheduledDeparture]);
        NSLog(@"----> EXpected Departure = %@", [(objTrainMovements*)[allTrain_sd objectAtIndex:i] ExpectedDeparture]);
        NSLog(@"----> Scheduled Arrival = %@", [(objTrainMovements*)[allTrain_sd objectAtIndex:i] ScheduledArrival]);
        NSLog(@"----> Expected Arrival = %@", [(objTrainMovements*)[allTrain_sd objectAtIndex:i] ExpectedArrival]);
        
    }
    
    if([[NSString stringWithString:[(objTrainMovements*)[allTrain_ft objectAtIndex:0] LocationCode]] isEqualToString:@"ARKLW"]) {
        self.startStationName.text = [NSString stringWithString:[listOfStationName objectAtIndex:0]];
        self.stopStationName.text = [NSString stringWithString:[listOfStationName objectAtIndex:2]];
    } else if([[NSString stringWithString:[(objTrainMovements*)[allTrain_ft objectAtIndex:0] LocationCode]] isEqualToString:@"SKILL"]) {
        self.startStationName.text = [NSString stringWithString:[listOfStationName objectAtIndex:2]];
        self.stopStationName.text = [NSString stringWithString:[listOfStationName objectAtIndex:0]];
    }
    
    self.departStartTime.text = [NSString stringWithFormat:@"%@ (Code %@)",[(objTrainMovements*)[allTrain_ft objectAtIndex:0] ExpectedDeparture],[(objTrainMovements*)[allTrain_ft objectAtIndex:0] TrainCode]];
    
    NSString *myBrayStopTime = [NSString stringWithString:[(objTrainMovements*)[allTrain_ft objectAtIndex:1] ExpectedArrival]];
    self.brayStopTime.text = [NSString stringWithFormat:@"%@ (Code %@)",myBrayStopTime,[(objTrainMovements*)[allTrain_ft objectAtIndex:1] TrainCode]];
    
    //we must select the first train starting from bray but with time departure > to  myBrayStopTime
    NSString *myBrayStartTime = [NSString string];
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *brayTimeStop = [myFormatter dateFromString:myBrayStopTime];
    for(int i=0; i < [allTrain_sd count]; i++) {
        NSDate *brayTimeStart = [myFormatter dateFromString:[(objTrainMovements*)[allTrain_sd objectAtIndex:i] ExpectedDeparture]];
        if([brayTimeStop compare:brayTimeStart] == NSOrderedAscending) {
            myBrayStartTime = [NSString stringWithString:[(objTrainMovements*)[allTrain_sd objectAtIndex:i] ExpectedDeparture]];
            break;
        }
    }
    
    if([myBrayStartTime length] != 0) {
        self.brayStartTime.text = [NSString stringWithFormat:@"%@ (Code %@)",myBrayStartTime,[(objTrainMovements*)[allTrain_sd objectAtIndex:0] TrainCode]];
    }
    self.stopEndTime.text = [NSString stringWithFormat:@"%@ (Code %@)",[(objTrainMovements*)[allTrain_sd objectAtIndex:1] ExpectedArrival],[(objTrainMovements*)[allTrain_sd objectAtIndex:1] TrainCode]];
}

-(void)fromSgtAction {
    NSLog(@"fromSgtAction");
    
    if([self.fromSgtCtrl selectedSegmentIndex] == 0) {
        self.toSgtCtrl.selectedSegmentIndex = 1;
    } else {
        self.toSgtCtrl.selectedSegmentIndex = 0;
    }
    
    if([self.fromSgtCtrl selectedSegmentIndex] == 0) {
        //load train code for this index
        [[IRDataManager sharedManagerData_Loader] loadTrainCode_forStationCode:@"ARKLW"];
        
    } else {
        //load train code for this index
        [[IRDataManager sharedManagerData_Loader] loadTrainCode_forStationCode:@"SKILL"];
    }
}

-(void)toSgtAction {
    NSLog(@"toSgtAction");
    
    if([self.toSgtCtrl selectedSegmentIndex] == 1) {
        self.fromSgtCtrl.selectedSegmentIndex = 0;
    } else {
        self.fromSgtCtrl.selectedSegmentIndex = 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
