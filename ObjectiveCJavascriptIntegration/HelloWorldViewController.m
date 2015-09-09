//
//  HelloWorldViewController.m
//  ObjectiveCJavascriptIntegration
//
//  Created by Gaston Montes on 2/9/15.
//  Copyright (c) 2015 Gaston Montes. All rights reserved.
//

#import "HelloWorldViewController.h"
#import "WebViewJavascriptBridge.h"

static NSString *const kHelloWorldResponseHandlerName       = @"JSSaysHelloWorld";
static NSString *const kObjectiveCSaysHelloToJSHandlerName  = @"ObjectiveCSaysHello";
static NSString *const kJSLogHandlerName                    = @"JSLogTextHandler";
static NSString *const kHelloWorldHTMLFileName              = @"HelloWorldJS";
static NSString *const kHelloWorldHTMLFileNameType          = @"html";

@interface HelloWorldViewController () <UIWebViewDelegate>

@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, weak) IBOutlet UITextView *recievedTextView;
@property (nonatomic, weak) IBOutlet UITextView *replyTextView;
@property (nonatomic, weak) IBOutlet UITextView *logTextView;

@end

@implementation HelloWorldViewController

#pragma mark - Nib methods.
- (NSString *)nibName
{
    return NSStringFromClass([HelloWorldViewController class]);
}

- (NSBundle *)nibBundle
{
    return [NSBundle mainBundle];
}

#pragma mark - View life cycle.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetTextViewsTexts];
    [self initializeJavascriptBridge];
}

#pragma mark - UIButtons actions.
- (IBAction)sayHelloToJSButtonAction:(id)sender
{
    self.replyTextView.text = @"";
    [self callJSResponseToHelloMethod];
}

- (IBAction)clearLogButtonAction:(id)sender
{
    self.logTextView.text = @"";
}

#pragma mark - Private Methods.
- (NSString *)timeStampString:(NSTimeInterval)timeStamp
{
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.YYYY HH:mm:ss.SSS"];
    
    return [dateFormatter stringFromDate:aDate];
}

- (void)logText:(NSString *)textToLog timeStamp:(NSTimeInterval)timeStamp
{
    NSString *newLogString  = [NSString stringWithFormat:@"%@ - %@", [self timeStampString:timeStamp], textToLog];
    self.logTextView.text   = [NSString stringWithFormat:@"%@ \n%@", newLogString, self.logTextView.text];
    NSLog(@"%@", textToLog);
}

#pragma mark - Web view methods.
- (void)loadHelloWorldHTMLPage {
    NSString* htmlPath  = [[NSBundle mainBundle] pathForResource:kHelloWorldHTMLFileName ofType:kHelloWorldHTMLFileNameType];
    NSString* appHtml   = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL      = [NSURL fileURLWithPath:htmlPath];
    
    [self logText:@"Objective C says: Loading HTML page." timeStamp:[[NSDate date] timeIntervalSince1970]];
    [self.webView loadHTMLString:appHtml baseURL:baseURL];
    //    self.webView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self logText:@"Objective C says: Finish loading HTML page." timeStamp:[[NSDate date] timeIntervalSince1970]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self logText:[error localizedDescription] timeStamp:[[NSDate date] timeIntervalSince1970]];
}

#pragma mark - Initialization methods.
- (void)resetTextViewsTexts
{
    self.recievedTextView.text  = @"";
    self.replyTextView.text     = @"";
    self.logTextView.text       = @"";
}

- (void)initializeJavascriptBridge
{
    self.webView = [[UIWebView alloc] init];
    
    // Initialize JS bridge.
    self.javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
                                                              handler:^(id data, WVJBResponseCallback responseCallback) {
                                                                  // Called when javascript send messages without calling any specific method.
                                                                  // This block should never be called. Use "registerHandler" method and response blocks.
                                                                  // Answer to JS using the response call back block.
                                                                  responseCallback(@"Objective C says: Message from JS recieved correctly.");
                                                              }];
    
    // Register methods that JS is going to call.
    [self registerLogMethod];
    [self registerJSSaysHelloWorldMethod];
    
    // Finally, load the hello world html page.
    [self loadHelloWorldHTMLPage];
}

#pragma mark - Javascript bridge handler methods.
- (void)callJSResponseToHelloMethod
{
    // Call JS 'ObjectiveCSaysHello' method and get the confirmation response.
    __weak HelloWorldViewController *safeMe = self;
    [self logText:@"Objective C says: Hello Javascript! How Are You?" timeStamp:[[NSDate date] timeIntervalSince1970]];
    [self.javascriptBridge callHandler:kObjectiveCSaysHelloToJSHandlerName
                                  data:@"Objective C says: Hello Javascript! How Are You?"
                      responseCallback:^(id response) {
                          [safeMe logText:@"Objective C says: JS confirmation message recieved." timeStamp:[[NSDate date] timeIntervalSince1970]];
                          [safeMe processThanksMessageWithData:response];
                      }];
}

- (void)registerLogMethod
{
    __weak HelloWorldViewController *safeMe = self;
    [self.javascriptBridge registerHandler:kJSLogHandlerName
                                   handler:^(id data, WVJBResponseCallback responseCallback) {
                                       // When JS calls kJSLogHandlerName method this block is going to be called.
                                       // Answer to JS using the response call back block.
                                       // Data: {"date": 12656754657, "message": "A message"}.
                                       NSString *message    = [data objectForKey:@"message"];
                                       NSNumber *dateNumber = [data objectForKey:@"date"];
                                       
                                       [safeMe logText:message timeStamp:[dateNumber doubleValue] / 1000];
                                       responseCallback([NSString stringWithFormat:@"Objective C says: text from JS logged correctly. Text: %@.", message]);
                                   }];
}

- (void)registerJSSaysHelloWorldMethod
{
    __weak HelloWorldViewController *safeMe = self;
    [self.javascriptBridge registerHandler:kHelloWorldResponseHandlerName
                                   handler:^(id data, WVJBResponseCallback responseCallback) {
                                       // When JS calls kHelloWorldResponseHandlerName method this block is going to be called.
                                       // Answer to JS using the response call back block.
                                       if ([data isKindOfClass:[NSString class]] == YES) {
                                           [safeMe processHelloWithData:data];
                                           responseCallback(@"Objective C says: 'Hello World' message from JS recieved correctly.");
                                           [safeMe logText:@"Objective C says: 'Hello World' message from JS recieved correctly." timeStamp:[[NSDate date] timeIntervalSince1970]];
                                       } else {
                                           responseCallback(@"Objective C says: JS 'Hello World' message has an unknown format.");
                                           [safeMe logText:@"Objective C says: JS 'Hello World' message has an unknown format." timeStamp:[[NSDate date] timeIntervalSince1970]];
                                       }
                                   }];
}

#pragma mark - Response call back methods.
- (void)processHelloWithData:(NSString *)helloWorldMessage
{
    self.recievedTextView.text = helloWorldMessage;
}

- (void)processThanksMessageWithData:(NSString *)thanksMessage
{
    self.replyTextView.text = thanksMessage;
}

@end
