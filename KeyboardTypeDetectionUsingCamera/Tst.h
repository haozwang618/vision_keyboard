//
//  Tst.h
//  KeyboardTypeDetectionUsingCamera
//
//  Created by Haozhu Wang on 11/17/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tst : NSObject
@property(nonatomic) NSString *letter;
@property double value;
@property double max;
@property(nonatomic) Tst * leftChild;
@property(nonatomic) Tst * middleChild;
@property(nonatomic) Tst * rightChild; 
/////
-(id) init: (NSString*) Letter;
-(id) init: (NSString*) Letter withMax:(double) maxVal;
-(id) initWithWord: (NSString*) word withValue:(double) val;
-(id) initWithFile;
/////
/*
-(void) setMaxValue;
-(double) leftMax;
-(double) middleMax;
-(double) rightMax;
////max child
-(Tst*) maxChild;
-(Tst*) maxLeftRight;
 */
/////inserting
-(Tst*) insertNode: (Tst*)node;
/*
-(Tst*) insertLeft: (Tst*)node;
-(Tst*) insertRight: (Tst*)node;
-(Tst*) insertMiddle: (Tst*)node;
 */
//////insert word
-(void) insertWord: (NSString*) word value: (double) value;
//////search letters
-(Tst*) searchFor:(NSString*) sl;
//-(Tst*) bubbleDown:(NSString*) sl;
-(NSMutableArray *) suggest: (NSString*) sl;
@end
