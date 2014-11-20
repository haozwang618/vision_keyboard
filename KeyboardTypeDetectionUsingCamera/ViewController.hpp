//
//  ViewController.h
//  KeyboardTypeDetectionUsingCamera
//
//  Created by Haozhu Wang on 2/8/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import "Tst.h"
using namespace cv;

@interface ViewController : UIViewController <CvVideoCameraDelegate>
@property(strong, retain)CvVideoCamera * cv_camera;

@property (strong, nonatomic) IBOutlet UILabel *typedTextiPad;
@property (strong, nonatomic) IBOutlet UILabel *typedText;
@property(nonatomic) CascadeClassifier noseDetect;
@property(nonatomic) CascadeClassifier leftEyeDetect;
@property(nonatomic) CascadeClassifier rightEyeDetect;
@property(nonatomic) CascadeClassifier pairEyesDetect;
@property(nonatomic) CascadeClassifier pairEyesDetectSmall;
@property (strong, nonatomic) UILabel *type;
@property (strong, nonatomic) Tst* suggestionTree;
@property (strong, nonatomic) Tst* suggestionTreeSoFar;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *padInd;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *phoneInd;
@property (strong, nonatomic) UIActivityIndicatorView *activityInd;
//@property(nonatomic) CascadeClassifier mouthDetect;
@property (strong, nonatomic) IBOutlet UIImageView *imageFeediPad;
@property (strong, nonatomic) IBOutlet UIImageView *imageFeed;
-(IBAction) switchButtonPress:(id)sender;
@end
