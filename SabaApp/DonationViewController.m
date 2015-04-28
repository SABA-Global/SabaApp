//
//  DonationViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/27/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DonationViewController.h"

// Third party library
#import <PayPalMobile.h>
#import <PayPalPayment.h>

@interface DonationViewController ()<PayPalPaymentDelegate>

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

@implementation DonationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	self.navigationItem.title = @"Donation";
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

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
	[self pay];
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
	
	//self.webViewController.didCompleteCallback = YES;
	//[self createFeedActivity:@"registered"];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
	NSLog(@"PayPal Payment Canceled");
	self.resultText = nil;
	self.successView.hidden = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
	
	//self.webViewController.didCompleteCallback = NO;
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

@end
