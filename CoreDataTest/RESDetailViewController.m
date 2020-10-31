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

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;
@property (weak, nonatomic) IBOutlet UITextField *kidCountTextField;
@end

@implementation RESDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSManagedObject *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}
- (IBAction)lastNameEditingDidEnd:(UITextField *)sender {
    [self.detailItem  setValue:sender.text forKey:@"lastname"];
}

- (IBAction)firstNameEditingDidEnd:(UITextField *)sender {
    [self.detailItem  setValue:sender.text forKey:@"firstname"];
}

- (IBAction)notesEditingDidEnd:(UITextField *)sender {
    [self.detailItem  setValue:sender.text forKey:@"notes"];
}

- (IBAction)kidsEditingDidEnd:(UITextField *)sender {
    [self.detailItem  setValue:@(sender.text.integerValue) forKey:@"kids"];
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
        self.firstNameTextField.text = [self.detailItem valueForKey:@"firstname"];
        self.lastNameTextField.text = [self.detailItem valueForKey:@"lastname"];
        self.notesTextField.text = [self.detailItem valueForKey:@"notes"];
        self.kidCountTextField.text = [NSString stringWithFormat:@"%@", [self.detailItem valueForKey:@"kids"]];
    }
}

@end
