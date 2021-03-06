//
//  MapViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoSessionModel;
@class UWTabBarController;

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) UWTabBarController *tabBarController;

@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@end
