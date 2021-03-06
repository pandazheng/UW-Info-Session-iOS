//
//  FeedbackViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 3/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PSPDFTextView.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "UIApplication+AppVersion.h"
#import "UIDevice-Hardware.h"
#import "UWColorSchemeCenter.h"

@implementation FeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    self.title = @"Feedback";
//    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:UWGold];
//    self.navigationController.navigationBar.tintColor = UWBlack;
    // Register Color Scheme Update Function
    [self updateColorScheme];
    [UWColorSchemeCenter registerColorSchemeNotificationForObserver:self selector:@selector(updateColorScheme)];
    
    //[self.tableView registerClass:[CenterTextCell class] forCellReuseIdentifier:@"CenterCell"];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _feedbackTextView = [[PSPDFTextView alloc] initWithFrame:CGRectMake(10, 10, screenSize.width - 20, screenSize.height - 262)];
    [_feedbackTextView setFont:[UWColorSchemeCenter helveticaNeueRegularFont:18]];
//    [_feedbackTextView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:_feedbackTextView];
    [_feedbackTextView becomeFirstResponder];
    
    NSLog(@"feed text view init");
    
    // observe keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

}

- (void)updateColorScheme {
    [self.navigationController.navigationBar setBarTintColor:[UWColorSchemeCenter uwGold]];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationController.navigationBar.tintColor = [UWColorSchemeCenter uwBlack];
                         [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UWColorSchemeCenter uwBlack]}];
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    LogMethod;
    CGSize keyboardSize;
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"%@", NSStringFromCGSize(keyboardSize));
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"screen: %@", NSStringFromCGSize(screenSize));
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // Change text view frame and scroll to bottom
                         [_feedbackTextView setFrame:CGRectMake(10, 10, screenSize.width - 20, screenSize.height - keyboardSize.height - 20)];
                         [_feedbackTextView scrollRangeToVisible:NSMakeRange(_feedbackTextView.  text.length - 1, 0)];
                     }
                     completion:nil];
    
}

- (void)keyboardWillChange:(NSNotification *)notification {
    LogMethod;
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//     NSLog(@"keyboard:  %@", NSStringFromCGSize(keyboardSize));
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//     NSLog(@"screen: %@", NSStringFromCGSize(screenSize));
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         [_feedbackTextView setFrame:CGRectMake(10, 10, screenSize.width - 20, screenSize.height - keyboardSize.height - 20)];
//                     }
//                     completion:nil];
}

- (void)keyboardDidChange:(NSNotification *)notification {
    LogMethod;
}

- (void)done {
    [self sendFeedback];
    //[ProgressHUD setAnimationDuration:3];
    //[ProgressHUD showSuccess:@"Thanks for your precious feedback!" Interacton:YES];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [SVProgressHUD showSuccessWithStatus:@"Thanks for your precious feedback!"];
    [self dismissViewControllerAnimated:YES completion:^(){}];
}
//
//- (void)testCompletion:(void (^)(void))block {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
//        [SVProgressHUD showSuccessWithStatus:@"Thanks for your precious feedback!"];
//        dispatch_queue_t aQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
//        dispatch_async(aQueue, block);
//    });
//}

- (void)sendFeedback {
    PFObject *feedback = [PFObject objectWithClassName:@"Feedback"];
    feedback[@"Device_Name"] = [[UIDevice currentDevice] name];
    //feedback[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
    feedback[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
    feedback[@"App_Version"] = [UIApplication appVersion];
    feedback[@"Feedback"] = _feedbackTextView.text;
    
    NSString *deviceType = [NSString stringWithFormat:@"%@ %@(%@)", [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] platform], [[UIDevice currentDevice] hwmodel]];
    feedback[@"Device_Type"] = deviceType;
    
    [feedback saveEventually];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

@end
