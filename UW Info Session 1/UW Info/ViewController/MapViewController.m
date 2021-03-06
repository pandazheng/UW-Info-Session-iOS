//
//  MapViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MapViewController.h"
#import "InfoSessionModel.h"
#import "UWTabBarController.h"
#import "UWGoogleAnalytics.h"

@interface MapViewController () <UIScrollViewAccessibilityDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation MapViewController {
    UILabel *showOrigin;
    BOOL barIsHidden;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set title
    self.title = @"Map of UWaterloo";
    
//    // show origin label
//    showOrigin =[[UILabel alloc] initWithFrame:(CGRectMake(10, 70, 190, 44))];
//    [self.view addSubview:showOrigin];
//    showOrigin.text = @"(%i, %i)";
//    [showOrigin setBackgroundColor:[UIColor yellowColor]];
    
//    UIButton *button =  [[UIButton alloc] initWithFrame:CGRectMake(30, 70, 190, 44)];
//    [button setTitle:@"ASDASDASDASD" forState:UIControlStateNormal];
//    [self.view addSubview:button];
    
    
    // set imageView
//    UIImage *map = [UIImage imageNamed:@"map_colour300.png"];
    //[InfoSessionModel saveMap];
    UIImage *map = [InfoSessionModel loadMap];
    [self.imageView setFrame:(CGRectMake(0, 0, map.size.width, map.size.height))];
    [self.imageView setImage:map];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setMultipleTouchEnabled:YES];
    //self.imageView.twoFingerTapIsPossible = YES;
    //multipleTouches = NO;
    
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidTopAndBottom:)];
//    [self.scrollView addGestureRecognizer:tapGesture];
    
    //[self.imageView addSubview:showOrigin];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setFrame:[[UIScreen mainScreen] bounds]];
    [self.scrollView setContentSize:self.imageView.frame.size];

    UITapGestureRecognizer *doubleTap;
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [singleTap setNumberOfTapsRequired:1];
    //[singleTap setDelegate:self];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setMinimumZoomScale:0.3];
    // ??
    [self.scrollView setAutoresizesSubviews:YES];
    
    [self.scrollView setZoomScale:0.4 animated:NO];
    [self.scrollView setContentOffset:CGPointMake(815, 365) animated:NO];

    self->barIsHidden = NO;
    
    // Google Analytics
    [UWGoogleAnalytics analyticScreen:@"Map Screen"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self showBars];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [showOrigin setText:[NSString stringWithFormat:@"offset: (%.2f, %.2f)\nzoom: %.2f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.zoomScale]];
//    //[showOrigin setText:[NSString stringWithFormat:@"offset: %@ \nzoom: %.2f", NSStringFromCGPoint(self.scrollView.contentOffset), self.scrollView.zoomScale]];
//    [showOrigin setNumberOfLines:0];
//}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollView Did End Scrolling Animation");
}

#pragma mark - tap method

- (void)handleSingleTap
{
    //    //Toggle visible/hidden status bar.
    //    //This will only work if the Info.plist file is updated with two additional entries
    //    //"View controller-based status bar appearance" set to NO and "Status bar is initially hidden" set to YES or NO
    //    //Hiding the status bar turns the gesture shortcuts for Notification Center and Control Center into 2 step gestures
    
    // hidden -> show
    if (self->barIsHidden) {
        [self showBars];
    }
    // show -> hidden
    else {
        [self hideBars];
    }
}

- (void)showBars {
    //NSLog(@"hidden -> show");
    //[self showStatusBar:YES];
    self->barIsHidden = NO;
    
    //    [[UIApplication sharedApplication]setStatusBarHidden:![[UIApplication sharedApplication]isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.5 animations:^
     {
         [self.navigationController.navigationBar setAlpha:1.0];
         //[self.navigationController.toolbar setAlpha:alpha];
         [_tabBarController showTabBar];
         
     } completion:^(BOOL finished)
     {
         
     }];
}

- (void)hideBars {
    //NSLog(@"show -> hidden");
    //[self showStatusBar:NO];
    self->barIsHidden = YES;
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.5 animations:^
     {
         [self.navigationController.navigationBar setAlpha:0.0];
         //[self.navigationController.toolbar setAlpha:alpha];
         [_tabBarController hideTabBar];
     } completion:^(BOOL finished)
     {
         
     }];
}

#pragma mark - Zoom methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [self.imageView frame].size.height / scale;
    zoomRect.size.width  = [self.imageView frame].size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self.scrollView];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"doubletaped");
    float newScale = [self.scrollView zoomScale] * 8.0;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
    
}

//- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
//{
//    float newScale = self.scrollView.zoomScale * 1.5;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
//    [self.scrollView zoomToRect:zoomRect animated:YES];
//}
//
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    CGRect zoomRect;
//    zoomRect.size.height = self.scrollView.frame.size.height / scale;
//    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
//    
//    center = [self.imageView convertPoint:center fromView:self.scrollView];
//    
//    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
//    return zoomRect;
//}
@end
