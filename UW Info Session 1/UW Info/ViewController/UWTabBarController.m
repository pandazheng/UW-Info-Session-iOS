//
//  UWTabBarController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWTabBarController.h"
#import "InfoSessionsViewController.h"
#import "MyInfoViewController.h"
#import "SearchViewController.h"
#import "DetailViewController.h"
#import "InfoSessionModel.h"
#import "UWColorSchemeCenter.h"
#import "UWDevice.h"

@interface UWTabBarController ()

@end

@implementation UWTabBarController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    LogMethod;
////    return UIStatusBarStyleLightContent;
//    return UIStatusBarStyleDefault;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _lastTapped = -1;

//    [self setNeedsStatusBarAppearanceUpdate];
    
    // Register Color Scheme Update Function
    [self updateColorScheme];
    [UWColorSchemeCenter registerColorSchemeNotificationForObserver:self selector:@selector(updateColorScheme)];
    
    UITabBarItem* item0 = [self.tabBar.items objectAtIndex:0];
    UITabBarItem* item1 = [self.tabBar.items objectAtIndex:1];
    UITabBarItem* item2 = [self.tabBar.items objectAtIndex:2];
    [item0 setSelectedImage:[UIImage imageNamed:@"List-selected"]];
    [item1 setSelectedImage:[UIImage imageNamed:@"star-tab-selected"]];
    [item2 setSelectedImage:[UIImage imageNamed:@"Search-selected"]];

    // Do any additional setup after loading the view.
    self.isHidden = NO;

    // Initiate three VC in tabbarController
    UINavigationController* navigationController = [self.viewControllers objectAtIndex:0];
    _infoSessionsViewController = (InfoSessionsViewController*)navigationController.viewControllers[0];
    _infoSessionsViewController.tabBarController = self;
    _infoSessionsViewController.infoSessionModel = self.infoSessionModel;

    navigationController = [self.viewControllers objectAtIndex:1];
    _myInfoViewController = (MyInfoViewController*)navigationController.viewControllers[0];
    _myInfoViewController.tabBarController = self;
    _myInfoViewController.infoSessionModel = self.infoSessionModel;

    navigationController = [self.viewControllers objectAtIndex:2];
    _searchViewController = (SearchViewController*)navigationController.viewControllers[0];
    _searchViewController.tabBarController = self;
    _searchViewController.infoSessionModel = self.infoSessionModel;

    [self setBadge];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:[UWColorSchemeCenter statusBarStyle]];
}

- (void)updateColorScheme {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tabBar.barTintColor = [UWColorSchemeCenter uwTabBarColor];
//                         self.tabBar.selectedImageTintColor = [UIColor redColor];
                         self.tabBar.tintColor = [UWColorSchemeCenter uwGold];
                         [self.tabBar setBackgroundColor:[UWColorSchemeCenter uwBlack]];
                     }
                     completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if targetIndex not equals -1, then need to show detailView
    if (_targetIndexTobeSelectedInMyInfoVC != -1) {
        [self setSelectedIndex:1];
        [_myInfoViewController reloadTable];
        [_myInfoViewController performSegueWithIdentifier:@"ShowDetailFromMyInfoSessions" sender:[[NSArray alloc] initWithObjects:@"MyInfoViewController", _infoSessionModel.myInfoSessions[_targetIndexTobeSelectedInMyInfoVC], _infoSessionModel, nil]];
    }
    
    // Shake gesture
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // Do your thing after shaking device
    if ([UWDevice sharedDevice].isRandomColor || [UWColorSchemeCenter sharedCenter].isTemporaryRandomColor) {
        [UWColorSchemeCenter updateColorScheme];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) {
        _detailViewControllerOfTabbar1.performedNavigation = @"Open Tabbar1";
        _detailViewControllerOfTabbar2.performedNavigation = @"Open Tabbar1";
        if (_lastTapped == 0) {
            // if first tab show InfoSessionsViewController then scroll to today
            UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
            if ([navigationController.topViewController isKindOfClass:[InfoSessionsViewController class]]) {
                [_infoSessionsViewController scrollToToday];
            }
        }
        _lastTapped = 0;

    } else if (item.tag == 1) {
        _detailViewControllerOfTabbar0.performedNavigation = @"Open Tabbar2";
        _detailViewControllerOfTabbar2.performedNavigation = @"Open Tabbar2";
        if (_lastTapped != 1) {
            [_myInfoViewController reloadTable];
        }
        _lastTapped = 1;
    } else {
        _detailViewControllerOfTabbar0.performedNavigation = @"Open Tabbar3";
        _detailViewControllerOfTabbar1.performedNavigation = @"Open Tabbar3";
        if (_lastTapped != 2) {
            [_searchViewController reloadTable];
        }
        if (_lastTapped == 2) {
            [_searchViewController scrollToFirstRow];
        }
        _lastTapped = 2;
    }
}

/**
 *  Hide tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) hideTabBar{
    if (!self.isHidden) {
        self.isHidden = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        float fHeight = screenRect.size.height;
        if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
        {
            fHeight = screenRect.size.width;
        }
        
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                view.backgroundColor = [UIColor whiteColor];
            }
        }
        [UIView commitAnimations];
    }
}

/**
 *  Show tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) showTabBar {
    if (self.isHidden) {
        self.isHidden = NO;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float fHeight = screenRect.size.height - self.tabBar.frame.size.height;
        
        if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
        {
            fHeight = screenRect.size.width - self.tabBar.frame.size.height;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            }
        }
        [UIView commitAnimations];
    }
}

/**
 *  set second tabbar's badge
 */
- (void)setBadge {
    UINavigationController *navigation = (UINavigationController *)self.viewControllers[1];
    // set badge
    NSInteger futureInfoSessions = [_infoSessionModel countFutureInfoSessions:_infoSessionModel.myInfoSessions];
    [[navigation tabBarItem] setBadgeValue: futureInfoSessions == 0 ? nil: NSIntegerToString(futureInfoSessions)];
}

@end
