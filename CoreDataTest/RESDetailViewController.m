//
//  RESDetailViewController.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 2013-07-14.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESDetailViewController.h"

@interface RESDetailViewController ()
- (void)configureView;

@end

@implementation RESDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

@end
