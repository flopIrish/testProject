//
//  IRSecondViewController.h
//  IrishRailRT
//

#import <UIKit/UIKit.h>

@interface IRSecondViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *myWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView *myWebView;

@end
