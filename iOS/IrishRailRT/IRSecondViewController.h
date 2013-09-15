//
//  IRSecondViewController.h
//  IrishRailRT
//
//  Created by Florence Jeulin on 10/09/13.
//  Copyright (c) 2013 Dauran SARL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRSecondViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *myWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView *myWebView;

@end
