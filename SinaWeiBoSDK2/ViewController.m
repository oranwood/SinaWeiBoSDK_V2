//
//  ViewController.m
//  SinaWeiBoSDK2
//
//  Created by 欧然 Wu on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "WBEngine.h"
#import "WBAuthorize.h"

@interface ViewController ()<WBAuthorizeDelegate, UIWebViewDelegate>{
    UIWebView *authWebView;
    
    UILabel *stateLB;
    UIButton *button;
}

@end

@implementation ViewController

- (void)loadView{
    [super loadView];
    authWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    authWebView.delegate = self;
    [self.view addSubview:authWebView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    WBEngine *engine = [WBEngine share];
    
    // Check if user has logged in, or the authorization is expired.
    if ([engine isLoggedIn] && ![engine isAuthorizeExpired]) {
        NSLog(@"WBEngine isLoggedIn");
        [engine readAuthorizeDataFromKeychain];
        NSLog(@"accessToken:   %@", engine.accessToken);
        NSLog(@"userID:        %@", engine.userID);
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:engine.expireTime];
        NSLog(@"expireTime:    %@", [date description]);
    }else{
        WBAuthorize *auth = [WBAuthorize share];
        auth.delegate = self;
        [auth setRedirectURI:@"http://"];
        NSString *urlString = [auth getRequestURL];
        //NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60.0];
        [authWebView loadRequest:request];
    }
}

- (void)authorize:(WBAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds{
    NSLog(@" WBAuthorizeDelegate didSucceedWithAccessToken");
    
    WBEngine *engine = [WBEngine share];
    engine.accessToken = accessToken;
    engine.userID = userID;
    engine.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    [engine saveAuthorizeDataToKeychain];

    NSLog(@"accessToken:   %@", engine.accessToken);
    NSLog(@"userID:        %@", engine.userID);
    NSLog(@"seconds:        %f", engine.expireTime);
    
    [authWebView removeFromSuperview];
    
    if (!stateLB) {
        stateLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        stateLB.backgroundColor = [UIColor clearColor];
        stateLB.numberOfLines = 20;
        [self.view addSubview:stateLB];
        stateLB.text = [NSString stringWithFormat:@"didSucceedWithAccessToken\naccessToken:   \n%@\nuserID:   \n%@\nexpiresIn:   \n%f", engine.accessToken, engine.userID, engine.expireTime];
    }
    
    //发送测试微博
    NSString *testText = [NSString stringWithFormat:@"TSET 超帅气的茶几鱼缸，让你的金鱼在自家的客厅里游遍全世界！ %f", engine.expireTime];
    //新浪不允许短时间内重复发送内容相同的微博 随机下engine.expireTime
    [engine sendWeiBoWithText:testText image:[UIImage imageNamed:@"6927f719jw1ducveyvqyij.jpg"]];
    
}

- (void)authorize:(WBAuthorize *)authorize didFailWithError:(NSError *)error{
    NSLog(@" WBAuthorizeDelegate didFailWithError");
    if (!stateLB) {
        stateLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        stateLB.backgroundColor = [UIColor clearColor];
        stateLB.numberOfLines = 20;
        [self.view addSubview:stateLB];
        stateLB.text = [NSString stringWithFormat:@"didFailWithErrorCode: %d", error.code];
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView{

}
- (void)webViewDidFinishLoad:(UIWebView *)webView{

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request.URL.absoluteString %@", request.URL.absoluteString);
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];   
        NSLog(@"aWebView code %@", code);
        if (![code isEqualToString:@"21330"])
        {
            [[WBAuthorize share] requestAccessTokenWithAuthorizeCode:code];            
        }
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
