//
//  Tst.m
//  KeyboardTypeDetectionUsingCamera
//
//  Created by Haozhu Wang on 11/17/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import "Tst.h"
#define MAX_SUG 5
@implementation Tst
@synthesize letter, value, max, leftChild, middleChild, rightChild;
NSString * const fileRead= @"wiktionary.txt";
int mid=0;
////////////////////////////////
-(id) init: (NSString*) Letter
{
    letter= Letter;
    max = -1;
    value = -1;
    return self;
}

-(id) init: (NSString*) Letter withMax:(double) maxVal
{
    self = [self init:Letter];
    max = maxVal;
    return self;
}

-(id) initWithWord: (NSString*) word withValue:(double) val
{
    Tst * first;
    Tst * cur;
    for (int i=0; i<[word length]; i++)
    {
        if (i==0) {
            first = [[Tst alloc] init: [NSString stringWithFormat:@"%c", [word characterAtIndex:i]]];
            cur = first;
        }
        else
        {
            cur = [cur insertMiddle:[[Tst alloc] init: [NSString stringWithFormat:@"%c", [word characterAtIndex:i]]]];
        }
    }
    cur.max = val;
    cur.value = val;
    [first setMaxValue];
    return first;
}

-(id) initWithFile
{
    NSArray * wikiFile = [fileRead componentsSeparatedByString:@"."];
    NSString* wikiPath = [[NSBundle mainBundle] pathForResource:wikiFile[0] ofType:@"txt"];
    NSString* fileContents = [NSString stringWithContentsOfFile:wikiPath
                              encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    NSString * first = [allLinedStrings objectAtIndex:1];
    NSMutableArray * valuesFirst=(NSMutableArray *)[first componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [valuesFirst removeObject:@""];
    NSLog([NSString stringWithFormat:@"value of %@ at %f",[valuesFirst objectAtIndex:1], [[valuesFirst objectAtIndex:0] doubleValue]]);
    
    Tst* firstOne = [self initWithWord:[valuesFirst objectAtIndex:1] withValue:[[valuesFirst objectAtIndex:0] doubleValue]];
    
    for (int i =2 ; i<[allLinedStrings count]; i++) {
        
        NSString * line = [allLinedStrings objectAtIndex:i];
        NSMutableArray * valueLine=(NSMutableArray *)[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        
        if (valueLine!=nil) {
            [valueLine removeObject:@""];
        
            [firstOne insertWord:[valueLine objectAtIndex:1] value:[[valueLine objectAtIndex:0] doubleValue]];
        }
    }
    return firstOne;
}

//////////////////////////////

-(double) leftMax
{
    if (leftChild!=nil) {
        [leftChild setMaxValue];
        return leftChild.max;
    }
    else
    {
        return -1;
    }
}

-(double) rightMax
{
    if (rightChild!=nil) {
        [rightChild setMaxValue];
        return rightChild.max;
    }
    else
    {
        return -1;
    }
}

-(double) middleMax
{
    if (middleChild!=nil) {
        [middleChild setMaxValue];
        return middleChild.max;
    }
    else
    {
        return max;
    }
}

-(void) setMaxValue
{
    max = MAX(MAX(self.leftMax, self.rightMax), self.middleMax);
}

/////insert
-(Tst*) insertNode: (Tst*)node
{
    mid = 0;
    if ((strcmp([node.letter cStringUsingEncoding:NSASCIIStringEncoding],[letter cStringUsingEncoding:NSASCIIStringEncoding]) < 0) &&(self.middleChild != nil))
    {
        //NSLog(@"left");
        return [self insertLeft:node];
    }
    else if((strcmp([node.letter cStringUsingEncoding:NSASCIIStringEncoding],[letter cStringUsingEncoding:NSASCIIStringEncoding]) > 0)&&(self.middleChild != nil))
    {
        //NSLog(@"right");
        return [self insertRight:node];
    }
    else
    {
        mid = 1;
        //NSLog(@"center");
        if (self.middleChild != nil){
            return self.middleChild;
        }
        else if((strcmp([node.letter cStringUsingEncoding:NSASCIIStringEncoding],[letter cStringUsingEncoding:NSASCIIStringEncoding]) == 0))
        {
            return self;
        }
        else
        {
            return [self insertMiddle:node];
        }
    }
}

-(Tst*) insertLeft: (Tst*)node
{
    if (self.leftChild == nil) {
        leftChild= node;
        return node;
    }
    else
    {
        return [leftChild insertNode:node];
    }
}
-(Tst*) insertRight: (Tst*)node
{
    if (self.rightChild == nil) {
        rightChild= node;
        return node;
    }
    else
    {
        return [rightChild insertNode:node];
    }

}
-(Tst*) insertMiddle: (Tst*)node
{
   
    self.middleChild = node;
    return node;
}

///////////////////////
-(void) insertWord: (NSString*) word value: (double) val
{
    Tst * cur;
    cur = [[Tst alloc] init: [NSString stringWithFormat:@"%c", [word characterAtIndex:0]]];
    cur = [self insertNode:cur];
    for (int i=1; i<[word length]; i++)
    {
        
        cur = [cur insertNode:[[Tst alloc] init: [NSString stringWithFormat:@"%c", [word characterAtIndex:i]]]];
        
    }
    cur.value= val;
    if (cur.value > cur.max) {
        cur.max= val;
    }
    [self setMaxValue];
}

///////////////////////
-(Tst*) searchFor:(NSString*) sl
{
    
    if ([self.letter isEqualToString:sl]) {
        if (middleChild == nil) {
            return nil;
        }
        else
        {
            return middleChild;
        }
    }
    else if (strcmp([self.letter cStringUsingEncoding:NSASCIIStringEncoding],[sl cStringUsingEncoding:NSASCIIStringEncoding]) > 0)
    {
        if (self.leftChild != nil)
        {
            return [self.leftChild searchFor:sl];
        }
        else{
            return nil;
        }
    }
    else if (strcmp([self.letter cStringUsingEncoding:NSASCIIStringEncoding],[sl cStringUsingEncoding:NSASCIIStringEncoding]) < 0)
    {
        if (self.rightChild != nil)
        {
            return [self.rightChild searchFor:sl];
        }
        else{
            return nil;
        }

    }
    
    return nil;
}
/*
-(Tst*) bubbleDown:(NSString*) sl
{
    if ([self.letter isEqualToString:sl]) {
        return self;
    }
    else if (strcmp([self.letter cStringUsingEncoding:NSASCIIStringEncoding],[sl cStringUsingEncoding:NSASCIIStringEncoding]) > 0)
    {
        if (self.leftChild != nil)
        {
            return [self.leftChild bubbleDown:sl];
        }
        else{
            return nil;
        }
    }
    else if (strcmp([self.letter cStringUsingEncoding:NSASCIIStringEncoding],[sl cStringUsingEncoding:NSASCIIStringEncoding]) < 0)
    {
        if (self.rightChild != nil)
        {
            return [self.rightChild bubbleDown:sl];
        }
        else{
            return nil;
        }
        
    }

    return nil;
}*/
///////////////max child

-(Tst*) maxChild
{
    Tst* maxLR= [self maxLeftRight];
    if (maxLR == nil) {
        return middleChild;
    }
    else
    {
        if (middleChild == nil) {
            return nil;
        }
        else
        {
            if (middleChild.max > maxLR.max) {
                return middleChild;
            }
            else
            {
                return maxLR;
            }
        }
    }
}

-(Tst*) maxLeftRight
{
    if (self.rightChild == nil) {
        if (self.leftChild == nil) {
            return nil;
        }
        else
        {
            return self.leftChild;
        }
    }
    else
    {
        if (leftChild != nil) {
            if (leftChild.max > rightChild.max) {
                return leftChild;
            }
            else
            {
                return rightChild;
            }
        }
        else
        {
            return rightChild;
        }
    }
}

-(Tst*) minLeftRight
{
    if (self.rightChild == nil) {
        if (self.leftChild == nil) {
            return nil;
        }
        else
        {
            return self.leftChild;
        }
    }
    else
    {
        if (leftChild != nil) {
            if (leftChild.max < rightChild.max) {
                return leftChild;
            }
            else
            {
                return rightChild;
            }
        }
        else
        {
            return rightChild;
        }
    }
}

-(Tst*) minChild
{
    Tst* minLR= [self minLeftRight];
    if (minLR == nil) {
        return middleChild;
    }
    else
    {
        if (middleChild == nil) {
            return nil;
        }
        else
        {
            if (middleChild.max < minLR.max) {
                return middleChild;
            }
            else
            {
                return minLR;
            }
        }
    }
}

-(Tst*) secondMax
{
        if([self minChild] == [self maxChild])
        {
            return [self minChild];
        }
        else
        {
            if (((self.leftChild == nil) || (self.rightChild == nil)) || (self.middleChild == nil)){
                return [self minChild];
            }
            else
            {
                if ((self.leftChild != [self minChild]) && (self.leftChild != [self maxChild])){
                    return self.leftChild;
                }
                else if ((self.rightChild != [self minChild]) && (self.rightChild != [self maxChild])) {
                    return self.rightChild;
                }
                    
                
                return self.middleChild;
            }
        }
}
//////
-(NSMutableArray *) suggest: (NSString*) sl
{
    Tst * found = [self searchFor:sl];
    NSLog(@"search successful!");
    if (found == nil) {
        return nil;
    }
    else{
        Tst* myMax = [found maxChild];
        Tst* imedMax = myMax;
        NSMutableArray * suggestion = [NSMutableArray alloc];
        if (myMax == nil) {
            return [suggestion initWithObjects:found, nil];
        }
        else
        {
            suggestion = [suggestion initWithObjects:myMax, nil];
            int count =1;
            if (myMax == middleChild) {
                myMax = [found maxLeftRight];
            }
            else
            {
                myMax = [myMax maxLeftRight];
            }
            if (myMax != nil) {
                [suggestion addObject:myMax];
            }
            
            while ((count< MAX_SUG) && (myMax!= nil)) {
                myMax = [myMax maxLeftRight];
                if (myMax != nil) {
                    [suggestion addObject:myMax];
                }
                count++;
            }
            if (count<MAX_SUG) {
                imedMax = [found secondMax];
                if (imedMax != [found maxChild]) {
                    count++;
                    [suggestion addObject:imedMax];
                    while ((count< MAX_SUG) && (imedMax!= nil)) {
                        imedMax = [imedMax maxLeftRight];
                        if (myMax != nil) {
                            [suggestion addObject:imedMax];
                        }
                        count++;
                    }

                }
            }
            [suggestion addObject:found];
            return suggestion;
        }
        
    }
}

@end
