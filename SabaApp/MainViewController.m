//
//  MainViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/23/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MainViewController.h"

// Third party imports
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <PayPalMobile.h>
#import <PayPalPayment.h>


// CollectionView Cell
#import "SabaCell.h"

// Client
#import "SabaClient.h"

// ViewControllers
#import "EventsViewController.h"
#import "ContactViewController.h"
#import "DonationViewController.h"
#import "SettingsViewController.h"
#import "PrayerTimesViewController.h"
#import "WeeklyScheduleViewController.h"

static NSString *SABA_BASE_URL = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=4";
//static NSString *SABA_BASE_URL = @"http://praytime.info/getprayertimes.php?school=0&gmt=-480";

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// PayPal integration stuff.
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(nonatomic, strong, readwrite)  UIButton *payNowButton;
@property(nonatomic, strong, readwrite)  UIButton *payFutureButton;
@property(nonatomic, strong, readwrite)  UIView *successView;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) NSString *resultText;
// end paypal...

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	[self.collectionView registerNib:[UINib nibWithNibName:@"SabaCell" bundle:nil] forCellWithReuseIdentifier:@"SabaCell"];
	[self.navigationController setNavigationBarHidden:YES];
	[self showDates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[self showDates];
}

#pragma CollectionView

// number of items in section
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return 4;
}

// sets the size of cell dynamically as per phone size.
- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
	CGSize size;
	
	size.height = self.collectionView.frame.size.height/2-2;
	size.width = self.collectionView.frame.size.width/2-1;
	
	return size;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	SabaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SabaCell" forIndexPath:indexPath];
	
	cell.layer.borderWidth = 0.5f;
	cell.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f
											 green:255.0f/255.0f
											  blue:255.0f/255.0f
											 alpha:1.0f].CGColor; // white
	switch(indexPath.row){
		case 0:
			cell.title.text			= @"Weekly \nSchedule";
			cell.imageView.image	= [UIImage imageNamed:@"calendar.png"];
			break;
		case 1:
			cell.title.text			= @"Events & \nAnnouncements";
			cell.imageView.image	= [UIImage imageNamed:@"megaphone.png"];
			break;
		case 2:
			cell.title.text			= @"Prayer Times";
			cell.imageView.image	= [UIImage imageNamed:@"pray.png"];
			break;
		case 3:
			cell.title.text			= @"Contact &\nDirections";
			cell.imageView.image	= [UIImage imageNamed:@"location.png"];
			break;
			
		default:
			break;
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	UIViewController *controller = nil;
	switch(indexPath.row){
		case 0:
			controller = [[WeeklyScheduleViewController alloc]init];
			break;
		case 1:
			controller = [[EventsViewController alloc]init];
			break;
		case 2:
			controller = [[PrayerTimesViewController alloc]init];
			break;
		case 3:
			controller = [[ContactViewController alloc]init];
			break;
			
		default:
			break;
	}
	
	// very important to set the NavigationController correctly.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
	nvc.navigationBar.translucent = YES; 

	[self presentViewController:nvc animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	[cell setSelected:YES];
}

#pragma mark Button clicked handlers

- (IBAction)donationBtnClicked:(id)sender {
	[self pay];
}

- (IBAction)settingBtnClicked:(id)sender {
	SettingsViewController *dvc = [[SettingsViewController alloc]init];
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dvc];
	nvc.navigationBar.translucent = NO; // so it does not hide details views
	
	[self presentViewController:nvc animated:YES completion:nil];
}

///------------------------- Following is the PayPal integration code for donations..............
#pragma mark PayPal Payment integration stuff

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.payPalConfig = [[PayPalConfiguration alloc] init];
		
		// See PayPalConfiguration.h for details and default values.
		// Should you wish to change any of the values, you can do so here.
		// For example, if you wish to accept PayPal but not payment card payments, then add:
		self.payPalConfig.acceptCreditCards = YES;
		// Or if you wish to have the user choose a Shipping Address from those already
		// associated with the user's PayPal account, then add:
		self.payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
	//[PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
	[PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
	
}

- (void)pay {
	// Remove our last completed payment, just for demo purposes.
	self.resultText = nil;
	
	// Note: For purposes of illustration, this example shows a payment that includes
	//       both payment details (subtotal, shipping, tax) and multiple items.
	//       You would only specify these if appropriate to your situation.
	//       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
	//       and simply set payment.amount to your total charge.
	
	// Optional: include multiple items
	PayPalItem *item1 = [PayPalItem itemWithName:@"Course"
									withQuantity:1
									   withPrice:[NSDecimalNumber decimalNumberWithString:@"0.99"]
									withCurrency:@"USD"
										 withSku:@"Inneract-01"];
	
	NSArray *items = @[item1];
	NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
	
	// Optional: include payment details
	NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0.00"];
	NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@".09"];
	PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
																			   withShipping:shipping
																					withTax:tax];
	
	NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
	
	PayPalPayment *payment = [[PayPalPayment alloc] init];
	payment.amount = total;
	payment.currencyCode = @"USD";
	payment.shortDescription = @"Final Cost";
	payment.items = items;  // if not including multiple items, then leave payment.items as nil
	payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
	
	if (!payment.processable) {
		// This particular payment will always be processable. If, for
		// example, the amount was negative or the shortDescription was
		// empty, this payment wouldn't be processable, and you'd want
		// to handle that here.
	}
	
	// Update payPalConfig re accepting credit cards.
	self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
	
	PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
																								configuration:self.payPalConfig
																									 delegate:self];
	[self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
	NSLog(@"PayPal Payment Success!");
	self.resultText = [completedPayment description];
	[self showSuccess];
	
	[self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
	[[[UIAlertView alloc] initWithTitle:@"Transaction complete" message:@"Complete" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
	NSLog(@"PayPal Payment Canceled");
	self.resultText = nil;
	self.successView.hidden = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
	// TODO: Send completedPayment.confirmation to server
	NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}

#pragma mark - Helpers

- (void)showSuccess {
	self.successView.hidden = NO;
	self.successView.alpha = 1.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:2.0];
	self.successView.alpha = 0.0f;
	[UIView commitAnimations];
}

// we will add Hijri date here too, Currently, it adds english date.
-(void) showDates{
	
	NSString* date = [NSDateFormatter localizedStringFromDate:[NSDate date]
													dateStyle:NSDateFormatterFullStyle
													timeStyle:NSDateFormatterNoStyle];
	self.englishDate.text = date;
}

-(void) refreshMainViewController{
	[self showDates];
}
@end
