//
//  G4ViewController.h
//  lier
//
//  Created by xu james on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface G4ViewController : UIViewController

-(void)finishPlay : (NSNotification *) n;
@property (assign) MPMoviePlayerController *mplayer;

@end
