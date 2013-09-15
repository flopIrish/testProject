//
//  IRSecondViewController.m
//  IrishRailRT
//
//  Created by Florence Jeulin on 10/09/13.
//  Copyright (c) 2013 Dauran SARL. All rights reserved.
//

#import "IRSecondViewController.h"

@interface IRSecondViewController ()

@end

@implementation IRSecondViewController

@synthesize myWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Planner", @"Planner");
        self.tabBarItem.image = [UIImage imageNamed:@"clock"];
    }
    return self;
}
							
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.myWebView.backgroundColor = [UIColor whiteColor];
	self.myWebView.scalesPageToFit = YES;
	self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    
    NSString *urlToDisplay = @"http://www.irishrail.ie/timetables";
	
	[self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlToDisplay]
												 cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
											 timeoutInterval:90]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.myWebView stopLoading];	// in case the web view is still loading its content
	self.myWebView.delegate = nil;	// disconnect the delegate as the webview is hidden
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	//NSLog(@"webViewDidStartLoad");
    // starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//NSLog(@"webViewDidFinishLoad ");
    // finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    // report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	//NSLog(@"didFailLoadWithError error=<%@>",error.localizedDescription);
	[self.myWebView loadHTMLString:errorString baseURL:nil];
}


@end
