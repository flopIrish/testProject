//
//  IRAppDelegate.h
//  IrishRailRT
//

#import <UIKit/UIKit.h>

@interface IRAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
