/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDParentUIViewController.h"



@interface QVDParentUIViewController ()

@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) NSString *pendingSegue;
@property (nonatomic) UIViewController *pendingSegueController;
@end

@implementation QVDParentUIViewController
@synthesize hasAppeared, pendingSegue, viewServices, clientWrapper, pendingSegueController;

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
	// Do any additional setup after loading the view.
    NSLog(@"%@: viewDidLoad", [ [ self class ] description]);
    self.clientWrapper = [ QVDClientWrapper instance ];
    self.viewServices = [ QVDViewServices instance ];
    self.hasAppeared = false;
    self.pendingSegue = nil;
    self.pendingSegueController = nil;
}

// Release any retained subviews of the main view.
- (void)viewDidUnload
{
    NSLog(@"%@: viewDidUnload", [ [ self class ] description]);
//    self.viewServices = nil;
//    self.clientWrapper = nil;
    [ super viewDidUnload ];
}

// Before unloading the view, save status
- (void)viewWillUnload {
    NSLog(@"%@: viewWillUnload", [ [ self class ] description]);
    [ super viewWillUnload];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"%@: didReceiveMemoryWarning", [ [ self class ] description]);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
    NSLog(@"%@: viewDidAppear: %d", [ [ self class ] description], animated);
    // TODO review what happens with pendingSegues and pendingSegueController
    [ self.viewServices setController:self];
    if (self.pendingSegue != nil && self.pendingSegueController != nil) {
        NSLog(@"%@: viewDidAppear perform delayed segue %@ for controller %@, with self %@", [ [ self class ] description], self.pendingSegue, self.pendingSegueController, self);
        if ([self isKindOfClass:[self.pendingSegueController class]]) {
            [ self performSegueWithIdentifier:self.pendingSegue sender:self];
        } else {
            NSLog(@"Not performing segue, classes are different");
        }
        self.pendingSegue = nil;
        //self.pendingSegueController = nil;
    }
    self.hasAppeared = true;
}

- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
    NSLog(@"%@: viewWillAppear: %d. Pending segue %@ for controller %@", [ [ self class ] description], animated, self.pendingSegue, self.pendingSegueController);

}
- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"%@: viewWillDissappear: %d", [ [ self class ] description], animated);
    //self.hasAppeared = false;
    self.pendingSegue = nil;
    self.pendingSegueController = nil;
    [ super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
    NSLog(@"%@: viewDidDisappear: %d", [ [ self class ] description], animated);
    self.hasAppeared = false;
    [ super viewDidDisappear:animated];
}

- (void) performDelayedSegueWithIdentifier:(NSString *)identifier {
    NSLog(@"%@ performDelayedSegueWithIdentifier %@", self, identifier);
    if (self.hasAppeared) {
        //__weak typeof(self) weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
            [ self performSegueWithIdentifier:identifier sender:self];
            self.pendingSegue = nil;
//            weakSelf.pendingSegueController = nil;
//        });
        return;
    }
    self.pendingSegue = identifier;
    self.pendingSegueController = self;
    NSLog(@"%@: Delaying segue %@", [ [self class] description ], self.pendingSegue);
    
}
@end
