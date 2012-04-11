//
//  G4ViewController.m
//  lier
//
//  Created by xu james on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MPMoviePlayerController.h>
#import "G4ViewController.h"
#import "G4GLView.h"

@implementation G4ViewController

@synthesize mplayer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication ] setStatusBarHidden:TRUE];
    NSURL *media = [[NSBundle mainBundle] URLForResource:@"Intro" withExtension:@"mp4"];
    
    if( media ) {
        MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:media];
        if(mp){
            self.mplayer = [mp retain];
            [mp release];
            UIImageView *iv ;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    iv = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"bg4.jpg"]];
                }else {
                   iv = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait~ipad.png"]];              
                }
            
            [iv addSubview:self.mplayer.view];
            [self.view addSubview:iv];
            [iv release];
            if( FALSE ) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlay:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.mplayer];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlay:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.mplayer];            
                
                self.mplayer.shouldAutoplay = NO;
                self.mplayer.controlStyle = MPMovieControlStyleNone;
                [self.mplayer.view setFrame:  [[UIScreen mainScreen] applicationFrame]];
                [self.mplayer.view setAlpha:0.0];
                [self.mplayer play];
            }
            else {
                UIView * v = [[G4GLView alloc] initWithFrame: self.view.bounds];
                [self.view addSubview: v];
                [v release];

            }
        }
    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return NO;
        //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return NO;
    }
}

-(void)finishPlay : (NSNotification *) n {
    
    NSLog(@" name %@  object %@  mplayer %@ self %@", [n name], [ n object],self,self.mplayer);
    
    if ([n object]== self.mplayer) {
        if( [[n name]  isEqualToString:@"MPMoviePlayerLoadStateDidChangeNotification"]) {
            NSLog(@"load stat %d", self.mplayer.loadState);
            if( self.mplayer.loadState != MPMovieLoadStateUnknown) {
                [NSThread sleepForTimeInterval:0.1];
                [self.mplayer.view setAlpha:1.0];
            }
            
        }
        else if ([[n name]  isEqualToString:@"MPMoviePlayerPlaybackDidFinishNotification"]) {
            [self.mplayer stop];
            [self.mplayer.view removeFromSuperview];
            [self.mplayer release];
            self.mplayer = nil;
             UIView * v = [[G4GLView alloc] initWithFrame: self.view.bounds];
            [self.view addSubview: v];
            [v release];

        }
    }
}

@end
