//
//  ViewController.m
//  KeyboardTypeDetectionUsingCamera
//
//  Created by Haozhu Wang on 2/8/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import "ViewController.hpp"
#import <math.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize imageFeed, cv_camera, noseDetect, typedText, rightEyeDetect, leftEyeDetect, pairEyesDetect, pairEyesDetectSmall;

NSString* const noseCascadeFilename=@"haarcascade_mcs_nose.xml";
NSString* const rightEyeCascadeFilename=@"haarcascade_mcs_righteye.xml";
NSString* const leftEyeCascadeFilename=@"haarcascade_mcs_lefteye.xml";
NSString* const pairEyesCascadeFilename=@"haarcascade_mcs_eyepair_big.xml";
NSString* const pairEyesSmallCascadeFilename=@"haarcascade_mcs_eyepair_small.xml";
const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT;
int counter=0;
NSMutableString *previous;
typedef enum _feature {
    NOSE,
    RIGHT_EYE,
    LEFT_EYE,
    PAIR_EYES
} Feature;

int two_pupil_counter=0;
int left_blink_counter=0;
int right_blink_counter =0;
bool calibrated = false;

int current =0;
int letter_counter=6;
int current_state=0;
bool selected= false;

//for calibration
int state_count=0;
int frame_count =0;
int inter_frame =0;
double left_speed=0;
double right_speed=0;
double up_speed=0;
double down_speed=0;

int fontFace = FONT_HERSHEY_PLAIN;
double fontScale = 3;
int thickness = 1;
//////

int previous_horizontal=0;
int frame_pass = 3;
int frame_pass_counter =0;
int frame_pass_counter_vert;
bool selectionFlag=false;

//
cv::Point chosenMidpoint;
cv::Point chosenLetter;

//////
int previous_quad = -1;
int count_quad = 0;
int letter_mode =0;
int count_non = 0;
int start_x;
int start_y;
/////
NSString * selected_str;
bool type_letters=false;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Frontcamera = false;

    
    //[self initializeCamera];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    previous =[[NSMutableString alloc] initWithFormat:@""];
    [typedText setText:@"<"];
    cv_camera = [[CvVideoCamera alloc] initWithParentView:imageFeed];

    cv_camera.defaultAVCaptureSessionPreset=AVCaptureSessionPreset352x288;
    cv_camera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationPortrait;
    cv_camera.grayscaleMode =NO;
    
    cv_camera.delegate=self;
    cv_camera.defaultAVCaptureDevicePosition= AVCaptureDevicePositionFront;
    
    NSArray * noseFile = [noseCascadeFilename componentsSeparatedByString:@"."];
    NSString* noseCascadePath = [[NSBundle mainBundle] pathForResource:noseFile[0] ofType:@"xml"];
    noseDetect.load([noseCascadePath  UTF8String]);
    
    NSArray * rightEyeFile = [rightEyeCascadeFilename componentsSeparatedByString:@"."];
    NSString* rightEyeCascadePath = [[NSBundle mainBundle] pathForResource:rightEyeFile[0] ofType:@"xml"];
    rightEyeDetect.load([rightEyeCascadePath  UTF8String]);
    
    NSArray * leftEyeFile = [leftEyeCascadeFilename componentsSeparatedByString:@"."];
    NSString* leftEyeCascadePath = [[NSBundle mainBundle] pathForResource:leftEyeFile[0] ofType:@"xml"];
    leftEyeDetect.load([leftEyeCascadePath  UTF8String]);
    
    NSArray * pairEyesFile = [pairEyesCascadeFilename componentsSeparatedByString:@"."];
    NSString* pairEyesCascadePath = [[NSBundle mainBundle] pathForResource:pairEyesFile[0] ofType:@"xml"];
    pairEyesDetect.load([pairEyesCascadePath  UTF8String]);
    
    NSArray * pairEyesFileSmall = [pairEyesSmallCascadeFilename componentsSeparatedByString:@"."];
    NSString* pairEyesSmallCascadePath = [[NSBundle mainBundle] pathForResource:pairEyesFileSmall[0] ofType:@"xml"];
    pairEyesDetectSmall.load([pairEyesSmallCascadePath  UTF8String]);
    
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
    //std::vector<cv::Point> noseCenter = [self findFeature:image part:NOSE];
    //std::vector<cv::Point> rightEyeCenter = [self findNose:image part:RIGHT_EYE];
    //std::vector<cv::Point> leftEyeCenter = [self findNose:image part:LEFT_EYE];
    std::vector<cv::Point> pairEyesCenter = [self findFeature:image part:PAIR_EYES];
    
    //if (calibrated)
    //{
        if(type_letters)
        {
            [self displayLetters:image center:pairEyesCenter text:selected_str];
        }
        else
        {
        
            if (letter_mode==0)
            {
                NSString * text1= @"A, B, C, D, E, F, G";
                NSString * text2= @"H, I, J, K, L, M, N";
                NSString * text3= @"O, P, Q, R, S, T, U";
                NSString * text4= @"V, W, X, Y, Z, De, Sp";

                [self partitionQuadLvl1:image center:pairEyesCenter text1:text1 text2:text2 text3:text3 text4:text4];
            }
            else if(letter_mode == 1)
            {
                [self partitionQuadLvl1:image center:pairEyesCenter text1:@"A,B" text2:@"C,D" text3:@"E,F" text4:@"G"];
            }
            else if(letter_mode == 2)
            {
                [self partitionQuadLvl1:image center:pairEyesCenter text1:@"H,I" text2:@"J,K" text3:@"L,M" text4:@"N"];
            }
            else if(letter_mode == 3)
            {
                [self partitionQuadLvl1:image center:pairEyesCenter text1:@"O,P" text2:@"Q,R" text3:@"S,T" text4:@"U"];
            }
            else if(letter_mode == 4)
            {
                [self partitionQuadLvl1:image center:pairEyesCenter text1:@"V,W" text2:@"X,Y" text3:@"Z,Sp" text4:@"De"];
            }
        }
   /* }
    else
    {
        //[self partitionQuad:image center:pairEyesCenter];
        [self calibration_stage:pairEyesCenter image:image];
    }*/
    /*
    cv::Scalar color =cvScalarAll(255);
    if(state_count >0)
    {
       
        cv::Point textOrg(10, 30);
        
        NSString* speed1=[NSString stringWithFormat:@"move left speed is %.4f",left_speed];
        
        cv::putText(image, [speed1 UTF8String], textOrg, fontFace, fontScale/4, color, thickness,4);
        if(state_count > 1)
        {
            cv::Point textOrg2(10, 50);
            NSString* speed2=[NSString stringWithFormat:@"move right speed is %.4f",right_speed];
            
            cv::putText(image, [speed2 UTF8String], textOrg2, fontFace, fontScale/4, color, thickness,4);

            if(state_count >2)
            {
                cv::Point textOrg3(10, 70);
                NSString* speed3=[NSString stringWithFormat:@"move up speed is %.4f",up_speed];
                
                cv::putText(image, [speed3 UTF8String], textOrg3, fontFace, fontScale/4, color, thickness,4);
                if(state_count >3)
                {
                    cv::Point textOrg4(10, 90);
                    NSString* speed4=[NSString stringWithFormat:@"move down speed is %.4f",down_speed];
                    
                    cv::putText(image, [speed4 UTF8String], textOrg4, fontFace, fontScale/4, color, thickness,4);
                    
                }
            }
        }
    }
    cv::Point textOrg5(10, 340);
    NSString* inter_frames=[NSString stringWithFormat:@"you have %d between frames",inter_frame];
    
    cv::putText(image, [inter_frames UTF8String], textOrg5, fontFace, fontScale/4, color, thickness,4);
    */
}


-(void) calibration_stage: (std::vector<cv::Point>) centerInp image:(Mat&) img
{
    /*cv::Point this_point;
    BOOL hasP= false;
    if (centerInp.size()>0) {
        cv::Point this_point= centerInp[1];
        hasP = true;
    }*/
    bool next = false;
    cv::Scalar color = cvScalar(255,255,255);
    
    cv::Point centerScreen(imageFeed.frame.size.width/2-15, imageFeed.frame.size.height/2+45);
        
    for (int i=0; i< centerInp.size(); ++i)
    {
        
        if (cv::norm(centerScreen - centerInp[i])<10) {
            color = cvScalar(0,255,0,255);
            
            
            if(frame_count<20)
            {
                frame_count++;
            }
            else if(frame_count == 20)
            {
                inter_frame=0;
            }
                
            break;
        }
        else if(frame_count == 20)
        {
            inter_frame++;
            
        }
        
    }
    
    if((state_count==0) && (frame_count==20))
    {
        state_count++;
        next = false;
    }
    if(state_count == 1)
    {
        cv::Point leftScreen(imageFeed.frame.size.width/2-60, imageFeed.frame.size.height/2+45);
        cv::Scalar leftColor = cvScalar(255,255,255);
        cv::circle(img, leftScreen, 15, leftColor);
        
        for (int i=0; i< centerInp.size(); ++i)
        {

            cv::line(img, centerInp[i], leftScreen, cvScalar(255,255,255));
            if(cv::norm(leftScreen-centerInp[i])<15)
            {
                
                //state_count++;
                left_speed=cv::norm(leftScreen-centerScreen)/inter_frame;
                frame_count =0;
                inter_frame = 0;
                next = true;
                
                break;
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    
    if((state_count==1) && (next))
    {
        state_count++;
        next= false;
    }
    if((state_count == 2) && (frame_count == 20))
    {
        cv::Point rightScreen(imageFeed.frame.size.width/2+30, imageFeed.frame.size.height/2+45);
        cv::Scalar rightColor = cvScalar(255,255,255);
        cv::circle(img, rightScreen, 15, rightColor);
        
        for (int i=0; i< centerInp.size(); ++i)
        {
            cv::line(img, centerInp[i], rightScreen, cvScalar(255,255,255));
            if(cv::norm(rightScreen-centerInp[i])<15)
            {
                //state_count++;
                right_speed=cv::norm(rightScreen-centerScreen)/inter_frame;
                frame_count =0;
                inter_frame = 0;
                next = true;
                break;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    
    if((state_count==2) && (next))
    {
        state_count++;
        next= false;
    }
    if((state_count == 3) && (frame_count == 20))
    {
        cv::Point topScreen(imageFeed.frame.size.width/2-15, imageFeed.frame.size.height/2-5);
        cv::Scalar topColor = cvScalar(255,255,255);
        cv::circle(img, topScreen, 15, topColor);
        
        for (int i=0; i< centerInp.size(); ++i)
        {
            cv::line(img, centerInp[i], topScreen, cvScalar(255,255,255));
            if(cv::norm(topScreen-centerInp[i])<15)
            {
                //state_count++;
                up_speed=cv::norm(topScreen-centerScreen)/inter_frame;
                frame_count =0;
                inter_frame = 0;
                next = true;
                break;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    
    if((state_count==3) && (next))
    {
        state_count++;
        next= false;
    }
    if((state_count == 4) && (frame_count == 20))
    {
        cv::Point downScreen(imageFeed.frame.size.width/2-15, imageFeed.frame.size.height/2+85);
        cv::Scalar downColor = cvScalar(255,255,255);
        cv::circle(img, downScreen, 15, downColor);
        
        for (int i=0; i< centerInp.size(); ++i)
        {
            cv::line(img, centerInp[i], downScreen, cvScalar(255,255,255));
            if(cv::norm(downScreen-centerInp[i])<15)
            {
                state_count++;
                down_speed=cv::norm(downScreen-centerScreen)/inter_frame;
                frame_count =0;
                inter_frame = 0;
                next = true;
                calibrated = true;
                break;
            }
        }
        
        
    }

    
    cv::circle(img, centerScreen, 15, color);

    
}

-(std::vector<cv::Point>) findFeature:(Mat&) image
                              part: (Feature) f
{
    Mat grayscaleFrame;
    cvtColor(image, grayscaleFrame, CV_BGR2GRAY);
    equalizeHist(grayscaleFrame, grayscaleFrame);
    CascadeClassifier tempClass;
    
    std::vector<cv::Point> centers;
    CvSize f_size;
    cv::Scalar color;
    switch (f) {
        case NOSE:
            tempClass = noseDetect;
            f_size =cv::Size(60, 60);
            color=cvScalar(0, 255, 0, 0);
            break;
            
        case RIGHT_EYE:
            tempClass = rightEyeDetect;
            f_size =cv::Size(50, 50);
            color=cvScalar(0, 255, 255, 0);
            break;
        
        case LEFT_EYE:
            tempClass = leftEyeDetect;
            f_size =cv::Size(50, 50);
            color=cvScalar(255,0,0,0);
            break;
            
        case PAIR_EYES:
            tempClass = pairEyesDetect;
            f_size =cv::Size(50, 50);
            color=cvScalar(0,0,255,0);
    }
    
    std::vector<cv::Rect> parts;
    tempClass.detectMultiScale(grayscaleFrame, parts, 1.1, 2, HaarOptions,f_size);
    if ((parts.size() == 0 ) && (f == PAIR_EYES))
    {
        tempClass = pairEyesDetectSmall;
        tempClass.detectMultiScale(grayscaleFrame, parts, 1.1, 2, HaarOptions,f_size);
    }
    for (int i = 0; i < parts.size(); i++)
    {
        cv::Point pt1(parts[i].x + parts[i].width, parts[i].y + parts[i].height);
        cv::Point pt2(parts[i].x, parts[i].y);
        
        cv::Point mid(parts[i].x + parts[i].width/2, parts[i].y + parts[i].height/2);
        centers.push_back(mid);
        
        //if(f== PAIR_EYES)
        //{
            //std::vector<std::vector<cv::Point> > contours = [self pairEyeSymetrySSD:grayscaleFrame rec:parts[i]];
            //NSLog([NSString stringWithFormat:@"there are %d contours found\n", (int)contours.size()]);
            //for (int j=0; j< contours.size(); j++)
            //{
                /*
                double area = cv::contourArea(contours[i]);    // Blob area
                cv::Rect rect = cv::boundingRect(contours[i]); // Bounding box
                int radius = rect.width/2;                     // Approximate radius
                
                if (area >= 10)// Look for round shaped blob
                                    cv::circle(image, cv::Point(rect.x + radius+parts[i].x, rect.y + radius+parts[i].y), radius, CV_RGB(255,0,0), 2);
                */
                
            //}
            
            /*if (!calibrated)
            {
                if (contours.size() == 2)
                {
                    two_pupil_counter = two_pupil_counter +1;
                    color = cvScalar(255,0,0,0);
                    if (two_pupil_counter > 30)
                        calibrated = true;
                }
                else if (contours.size() == 0)
                {
                    two_pupil_counter = 0;
                }
                
                    
            }
            else
            {
                color = cvScalar(0,255,0,0);
                if(contours.size() < 2)
                {
                    if(contours.size()==1)
                    {
                        cv::Rect bound= boundingRect(contours[i]);
                        if (bound.x < parts[i].x+ parts[i].width/2)  {
                            color=cvScalar(0,255,255,0);
                            //if(![previous isEqual:@""])
                            //{
                                right_blink_counter++;
                                left_blink_counter=0;
                            
                            
                                if ((counter > 8)&& (right_blink_counter >8))
                                {
                                //previous=[NSMutableString stringWithFormat:@"%@%@",previous,letter];
                                
                                    if(current<5)
                                    {
                                        [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@%@<",[[typedText text] substringToIndex:[[typedText text] length]-1],previous] waitUntilDone:YES];
                                    }
                                    else
                                    {
                                        if([previous isEqual:@"Sp"])
                                        {
                                                [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@ <",[[typedText text] substringToIndex:[[typedText text] length]-1]] waitUntilDone:YES];
                                        }
                                        else if([previous isEqual:@"De"])
                                        {
                                            [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@<",[[typedText text] substringToIndex:[[typedText text] length]-2]] waitUntilDone:YES];
                                        }
                                    }
                                //[typedText setText:[NSMutableString stringWithFormat:@"%@%@",[typedText text],previous]];
                                    counter =0;
                                    right_blink_counter = 0;
                                    calibrated = false;
                                    two_pupil_counter = 0;
                                
                                    NSLog([NSMutableString stringWithFormat:@"this label string is %@",[typedText text]]);
                                }
                            //}

                            
                        }
                        else
                        {
                            left_blink_counter++;
                            right_blink_counter=0;
                            color=cvScalar(255,255,0);
                            if(left_blink_counter>8)
                            {
                                left_blink_counter=0;
                                calibrated = false;
                                two_pupil_counter = 0;
                                
                                ++current_state;
                                current = current_state % letter_counter;
                            }
                        }
                    }
                    else
                    {
                        calibrated = false;
                        two_pupil_counter = 0;
                        
                    }
                }
                
            }
            
            //cv::drawContours(image, contours, -1, CV_RGB(255,255,255), -1);
        }*/
        
        cv::rectangle(image, pt1, pt2, color, 1, 8 ,0);
    }

    return centers;
}

-(std::vector<std::vector<cv::Point> >) pairEyeSymetrySSD:(Mat&) image rec:(cv::Rect) part
{
    Mat thisMat = image(cv::Range(part.y, part.y+part.height), cv::Range(part.x, part.x+part.width));
    
    cv::threshold(thisMat, thisMat, 20, 255, cv::THRESH_BINARY_INV);

    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(thisMat.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    cv::drawContours(thisMat, contours, -1, CV_RGB(255,255,255), -1);
    
    std::vector<std::vector<cv::Point>> new_contours;
    for (int i=0;i<contours.size();i++)
    {
        
        double area = cv::contourArea(contours[i]);    // Blob area
        cv::Rect rect = cv::boundingRect(contours[i]); // Bounding box
        int radius = rect.width/2;                     // Approximate radius
        
        // Look for round shaped blob
        if (area >= 15 &&
            std::abs(1 - ((double)rect.width / (double)rect.height)) <= 0.6 &&
            std::abs(1 - (area / (CV_PI * std::pow(radius, 2)))) <= 0.6)
        {
            std::vector<cv::Point> new_point_sets;
            std::vector<cv::Point> point_sets= contours.at(i);

        
            for (int j=0;j<point_sets.size();j++)
            {
                new_point_sets.push_back((cv::Point(point_sets.at(j).x+ part.x,point_sets.at(j).y+ part.y)));
            }
            new_contours.push_back(new_point_sets);
        }
        
    }
    return new_contours;
}

-(void) partitionQuadLvl1: (Mat&) image center:(std::vector<cv::Point>) eyeCenter text1: (NSString*) text1 text2:(NSString*) text2 text3:(NSString*) text3  text4:(NSString*) text4
{
    int res = [self partitionQuad:image center:eyeCenter];
    
    CvScalar color2 =cvScalar(255, 255, 255, 255);
    CvScalar color1 =cvScalar(0, 0, 255,255);
    CvScalar color3 =cvScalar(0, 255, 255,255);
    
    bool highlight = false;
    for(int i =1; i< 5; i++)
    {
        NSString * this_text;
        switch (i) {
            case 1:
                this_text = text1;
                break;
                
            case 2:
                this_text = text2;
                break;
            
            case 3:
                this_text = text3;
                break;
            
            case 4:
                this_text = text4;
                break;
        }
        
        if (i == res)
        {
            highlight = true;
            if (res == previous_quad)
            {
                count_quad++;
                count_non=0;
            }
            else
            {
                if(count_quad > 20)
                {
                    /*int change = fabs(res-previous_quad);
                    NSLog([NSString stringWithFormat:@"change is %d",change]);*/
                    /*if (letter_mode != 0)
                    {
                        letter_mode = 0;
                    }*/
                }
                
                else
                {
                    
                    previous_quad = res;
                }
                count_quad = 0;
            }
            
            if(count_quad>20)
            {
                //[self partitionQuadLetterHighlight:image color:color3 quad:i text:this_text];
                if(letter_mode != 0)
                {
                    type_letters = true;
                    switch (previous_quad) {
                        case 1:
                            selected_str = text1;
                            break;
                            
                        case 2:
                            selected_str = text2;
                            break;
                        case 3:
                            selected_str = text3;
                            break;
                        case 4:
                            selected_str = text4;
                            break;
                    }
                    
                }
                else
                {
                    letter_mode = previous_quad;
                }

                count_quad=0;
            }
            else
            {
                [self partitionQuadLetterHighlight:image color:color1 quad:i text:this_text];
            }
        }
        else
        {
            [self partitionQuadLetterHighlight:image color:color2 quad:i text:this_text];
        }
    }
    if(!highlight)
    {
        count_quad = 0;
        count_non++;
        if (count_non > 21) {
            letter_mode = 0;
        }
    }
}

-(void) partitionQuadLetterHighlight:(Mat&) image color:(CvScalar) color quad:(int) quadNum text:(NSString*) text
{
    NSArray* letters =[text componentsSeparatedByString:@", "];
    int row_start_offset=0;
    int col_start_offset=0;
    switch (quadNum) {
        case 2:
                col_start_offset= imageFeed.frame.size.height/2 +20;
                break;
        
        case 3:
                row_start_offset = imageFeed.frame.size.width/2-15;
                break;
        
        case 4:
                col_start_offset= imageFeed.frame.size.height/2 +20;
                row_start_offset = imageFeed.frame.size.width/2-15;
                break;
    }
    
    
    int count=1;
    int col_mult =0;
    int row_mult =0;
    int col_offset =0;
    int row_offset =0;
    for(NSString *letter in letters)
    {
        cv::Point textOrg(25 + row_start_offset+ row_offset, 45 + col_start_offset+col_offset);
        cv::putText(image, [letter UTF8String], textOrg, fontFace, fontScale, color, thickness,4);
        
        
        if (count % 2 ==0) {
            col_mult++;
            row_mult=0;
        }
        else
        {
            row_mult++;
        }
        
        col_offset = col_mult * 30;
        row_offset = row_mult * 30;
        count++;
    }
}

-(int) partitionQuad: (Mat&) image center:(std::vector<cv::Point>) eyeCenter
{
    int half_width_point =imageFeed.frame.size.width/2-15;
    int half_height_point = imageFeed.frame.size.height/2 +20;
    cv::Point midpoint1(0, half_height_point);
    cv::Point midpoint2(imageFeed.frame.size.width, half_height_point);
    
    cv::Point midmidpoint(half_width_point, half_height_point);
    
    cv::Point midpoint3(half_width_point, 0);
    cv::Point midpoint4(half_width_point, imageFeed.frame.size.height+30);
    
    CvScalar color2 =cvScalar(255, 255, 255, 255);
    CvScalar color1 =cvScalar(0, 0, 255,255);
    bool left = false;
    bool right = false;
    bool up = false;
    bool down = false;
    
    if ((eyeCenter.size() > 0) && (eyeCenter[0].x < midmidpoint.x))
    {
        cv::line(image, midpoint1, midmidpoint, color1);
        left = true;
    }
    else
    {
        cv::line(image, midpoint1, midmidpoint, color2);
    }
    
    if ((eyeCenter.size() > 0) && (eyeCenter[0].x > midmidpoint.x))
    {
        cv::line(image, midmidpoint, midpoint2, color1);
        right = true;
    }
    else
    {
        cv::line(image, midmidpoint, midpoint2, color2);
    }
    
    if ((eyeCenter.size() > 0) && (eyeCenter[0].y < midmidpoint.y))
    {
        cv::line(image, midpoint3, midmidpoint, color1);
        up = true;
    }
    else
    {
        cv::line(image, midpoint3, midmidpoint, color2);
    }
    
    if ((eyeCenter.size() > 0) && (eyeCenter[0].y > midmidpoint.y))
    {
        cv::line(image, midmidpoint, midpoint4, color1);
        down = true;
    }
    else
    {
        cv::line(image, midmidpoint, midpoint4, color2);
    }
    
    
    if(left && up)
    {
        return 1;
    }
    else if (left && down)
    {
        return 2;
    }
    else if (right && up)
    {
        return 3;
    }
    else if (right && down)
    {
        return 4;
    }
    
    
    return 0;
}

-(void) displayLetters:(Mat&) image center:(std::vector<cv::Point>) noseCenter text: (NSString*) text
{
    //NSString * text = @"A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, Sp, De";
    /*NSString * text;
    switch(current)
    {
        case 0:
            text = [NSString stringWithFormat:@"A, E, I, O, U"];
            break;
        case 1:
            text = [NSString stringWithFormat:@"B, C, D, F, G, Z"];
            break;
        case 2:
            text = [NSString stringWithFormat:@"H, J, K, L, M"];
            break;
        case 3:
            text = [NSString stringWithFormat:@"N, P, Q, R, S"];
            break;
        case 4:
            text = [NSString stringWithFormat:@"T, V, W, X, Y"];
            break;
        case 5:
            text = [NSString stringWithFormat:@"Sp, De"];
            break;
    }*/
    
    NSArray* letters =[text componentsSeparatedByString:@","];
    
    int letter_offset =0;
    int count =0;
    //int count2 =0;
    int height_offset=45;
    selected =false;
    for(NSString *letter in letters)
    {
        int letter_s= [letter length]*20;
        cv::Scalar color =cvScalarAll(255);
        cv::Point textOrg(imageFeed.frame.size.width/3+count*(letter_s+20)+letter_offset, imageFeed.frame.size.height/2+height_offset);
        
        cv::Point midTextOrg(imageFeed.frame.size.width/3+count*(letter_s+20)+letter_s/2+letter_offset, imageFeed.frame.size.height/2+height_offset-(letter_s+10)/2);
        
        for (int i = 0; i < noseCenter.size(); i++)
        {
            
            if ((cv::norm(noseCenter[i] - midTextOrg) < 17))
            {
             
                selected=true;
                inter_frame =0;
                if(frame_count< 31)
                {
                    color = cvScalar(0,0,255,255);
                    frame_count++;
                }
                else
                {
                    chosenMidpoint = midTextOrg;
                    color = cvScalar(0,255,255,255);
                    selectionFlag = true;
                    
                }
                
                previous=[NSMutableString stringWithFormat:@"%@",letter];
                //start typing
                
                if([letter isEqualToString:previous])
                {
                    counter = counter +1;
                    count_non = 0;
                }
                else
                {
                    previous=[NSMutableString stringWithFormat:@"%@",letter];
                    counter =0;
                    right_blink_counter = 0;
                    frame_count=0;
                }
                
                
                if (counter > 30)
                {
                    //previous=[NSMutableString stringWithFormat:@"%@%@",previous,letter];
                    
                    if([previous isEqualToString:@"Sp"])
                    {
                        [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@ ",[typedText text]]  waitUntilDone:YES];
                    }
                    else if([previous isEqualToString:@"De"])
                    {
                        [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@",[[typedText text] substringToIndex:[[typedText text] length]-1]] waitUntilDone:YES];
                    }
                    else
                    {
                        [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@%@",[typedText text],previous] waitUntilDone:YES];
                    }

                    
                    //[self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@%@",[typedText text],previous] waitUntilDone:YES];
                    //[typedText setText:[NSMutableString stringWithFormat:@"%@%@",[typedText text],previous]];
                    counter =0;
                    NSLog([NSMutableString stringWithFormat:@"this label string is %@",[typedText text]]);
                }
                
                
            }
            
            
            
            //else
            //{
            //    previous = [NSMutableString stringWithFormat:@""];
            //}
            
        }
        
        cv::putText(image, [letter UTF8String], textOrg, fontFace, fontScale, color, thickness,4);
        count++;
        /*
        if (imageFeed.frame.size.width - (imageFeed.frame.size.width/3+count*letter_s) < 2*letter_s + imageFeed.frame.size.width/4)
        {
            count2++;
            count = 0;
        }*/
    }
    
    if (!selected)
    {
        count_non++;
        if(count_non > 41)
        {
            type_letters = false;
            letter_mode = 0;
            
        }
        frame_count=0;
        count=0;
        /*inter_frame++;
        frame_count = 0;
        for (int i = 0; i < noseCenter.size(); i++)
        {
            double diff =(double)(noseCenter[i].y-chosenMidpoint.y);
            double diff2 =(double)(noseCenter[i].x-chosenMidpoint.x);
        
            double speed = fabs(diff/(double)inter_frame);
            double speed2 = fabs(diff/(double)inter_frame);

            
                if ((diff < 0)&&(speed > up_speed))
                {
                    
                    //previous=[NSMutableString stringWithFormat:@"%@%@",previous,letter];
                    if([previous isEqualToString:@"Sp"])
                    {
                         [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@ ",[[typedText text] substringToIndex:[[typedText text] length]-1]] waitUntilDone:YES];
                    }
                    else if([previous isEqualToString:@"De"])
                    {
                         [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@",[[typedText text] substringToIndex:[[typedText text] length]-1]] waitUntilDone:YES];
                    }
                    else
                    {
                        [self.typedText performSelectorOnMainThread : @selector(setText : ) withObject:[NSMutableString stringWithFormat:@"%@%@",[typedText text],previous] waitUntilDone:YES];
                    }
                    selectionFlag=false;
                    inter_frame=0;
                    
                }
                else if ((diff > 0)&&(speed > down_speed))
                {
                    type_letters = false;
                    letter_mode = 0;
                    
                }
            
                //NSLog([NSMutableString stringWithFormat:@"up speed is %f", speed]);
            
                else if ((diff2 > 0)&&(speed2 > right_speed))
                {
                    letter_offset = letter_offset+20;
                    selectionFlag=false;
                    inter_frame=0;
                    NSLog([NSMutableString stringWithFormat:@"right speed is %f", speed2]);
                    
                }
                else if ((diff2 < 0) &&(speed2 > left_speed))
                {
                    letter_offset = letter_offset-20;
                    selectionFlag=false;
                    inter_frame=0;
                    NSLog([NSMutableString stringWithFormat:@"left speed is %f", speed2]);
                    
                }
                NSLog([NSMutableString stringWithFormat:@"side speed is %f", speed2]);

            
         
        }*/
        /*
         double diff2 =(double)(noseCenter[i].x-midTextOrg.x);
         double speed2 = fabs(diff/(double)inter_frame);
         if ((diff2 > 0)&&(speed2 > right_speed))
         {
         letter_offset = letter_offset+20;
         NSLog([NSMutableString stringWithFormat:@"right speed is %f", speed2]);
         
         }
         else if ((diff2 < 0) &&(speed2 > left_speed))
         {
         letter_offset = letter_offset-20;
         NSLog([NSMutableString stringWithFormat:@"left speed is %f", speed2]);
         
         }
         NSLog([NSMutableString stringWithFormat:@"side speed is %f", speed2]);*/
        
        
    }
}
#endif

@end
