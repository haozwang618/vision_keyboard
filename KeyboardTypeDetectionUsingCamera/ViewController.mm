//
//  ViewController.m
//  KeyboardTypeDetectionUsingCamera
//
//  Created by Haozhu Wang on 2/8/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import "ViewController.hpp"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize imageFeed, cv_camera, noseDetect;

NSString* const noseCascadeFilename=@"haarcascade_mcs_nose.xml";
const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Frontcamera = false;
    
    
    //[self initializeCamera];
    cv_camera = [[CvVideoCamera alloc] initWithParentView:imageFeed];

    cv_camera.defaultAVCaptureSessionPreset=AVCaptureSessionPreset352x288;
    cv_camera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationPortrait;
    cv_camera.grayscaleMode =NO;
    
    cv_camera.delegate=self;
    cv_camera.defaultAVCaptureDevicePosition= AVCaptureDevicePositionFront;
    
    NSArray * line = [noseCascadeFilename componentsSeparatedByString:@"."];
    NSString* noseCascadePath = [[NSBundle mainBundle] pathForResource:line[0] ofType:@"xml"];
    noseDetect.load([noseCascadePath  UTF8String]);
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [cv_camera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) switchButtonPress:(id)sender
{

    [cv_camera stop];
    if  (cv_camera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack)
    {
        cv_camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    else
    {
        cv_camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    }
    [cv_camera start];
    
}

- (void) orientationChanged:(NSNotification *)note
{
    [cv_camera stop];
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            cv_camera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationPortrait;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            
            /* start special animation */
            cv_camera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationLandscapeLeft;
            break;
        
        case UIDeviceOrientationLandscapeRight:
            
            /* start special animation */
            cv_camera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationLandscapeRight;
            break;

        default:
            break;
    };
    [cv_camera start];
}

#ifdef __cplusplus
- (void)processImage:(Mat&)image
{
     std::vector<cv::Point> noseCenter = [self findNose:image];
    
    [self displayLetters:image center:noseCenter];
}

-(std::vector<cv::Point>) findNose:(Mat&) image
{
    Mat grayscaleFrame;
    cvtColor(image, grayscaleFrame, CV_BGR2GRAY);
    equalizeHist(grayscaleFrame, grayscaleFrame);
    
    std::vector<cv::Point> noseCenter;
    
    std::vector<cv::Rect> noses;
    noseDetect.detectMultiScale(grayscaleFrame, noses, 1.1, 2, HaarOptions, cv::Size(60, 60));
    for (int i = 0; i < noses.size(); i++)
    {
        cv::Point pt1(noses[i].x + noses[i].width, noses[i].y + noses[i].height);
        cv::Point pt2(noses[i].x, noses[i].y);
        
        cv::Point mid(noses[i].x + noses[i].width/2, noses[i].y + noses[i].height/2);
        noseCenter.push_back(mid);
        
        cv::rectangle(image, pt1, pt2, cvScalar(0, 255, 0, 0), 1, 8 ,0);
    }

    return noseCenter;
}

-(void) displayLetters:(Mat&) image center:(std::vector<cv::Point>) noseCenter
{
    NSString * text = @"A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z";
    
    NSArray* letters =[text componentsSeparatedByString:@", "];
    
    int fontFace = FONT_HERSHEY_PLAIN;
    double fontScale = 4;
    int thickness = 1;
    int count =0;
    int count2 =0;
    int letter_s= 40;
    for(NSString *letter in letters)
    {
        cv::Scalar color =cvScalarAll(255);
        cv::Point textOrg(20+count*letter_s, 120+count2*(letter_s+10));
        
        cv::Point midTextOrg(20+count*letter_s+letter_s/2, 120+count2*(letter_s+10)-(letter_s+10)/2);
        
        for (int i = 0; i < noseCenter.size(); i++)
        {
            if (cv::norm(noseCenter[i] - midTextOrg) < 17)
            {
                color = cvScalar(0,0,255,255);
            }
        }
        
        cv::putText(image, [letter UTF8String], textOrg, fontFace, fontScale, color, thickness,4);
        count++;
        
        if (imageFeed.frame.size.width - (10+count*letter_s) < letter_s + 40)
        {
            count2++;
            count = 0;
        }
    }
}
#endif

@end
