//
//  KeyboardTypeDetectionUsingCameraTests.m
//  KeyboardTypeDetectionUsingCameraTests
//
//  Created by Haozhu Wang on 2/8/14.
//  Copyright (c) 2014 Haozhu Wang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tst.h"

@interface KeyboardTypeDetectionUsingCameraTests : XCTestCase

@end
Tst * testNode;
@implementation KeyboardTypeDetectionUsingCameraTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testNode = [[Tst alloc] initWithWord:@"the" withValue:1000];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    Tst* temp;
    temp = testNode;
    while (temp!= nil) {
        NSLog(@"test node letter is %@, value is %f", temp.letter, temp.max);
        temp = temp.middleChild;
    }
    [testNode insertWord:@"there" value:2000];
    temp = testNode;
    
    while (temp!= nil) {
        NSLog(@"test node letter is %@, value is %f", temp.letter, temp.max);
        temp = temp.middleChild;
    }
    
    [testNode insertWord:@"buck" value:10];
    
    
    temp = testNode;
    temp = temp.leftChild;
    NSLog(@"test node letter is %@, value is %f", temp.letter, temp.max);
    
    
    while (temp!= nil) {
        NSLog(@"test node letter is %@, value is %f", temp.letter, temp.max);
        temp = temp.middleChild;
    }
    
    Tst* testWithFile = [[Tst alloc] initWithFile];
    NSLog(@"from file successful");
    NSArray * suggestions = [testWithFile suggest:@"t"];
    for (int i = 0; [suggestions count]; i++) {
        Tst* temp = [suggestions objectAtIndex:i];
        NSLog([NSString stringWithFormat:@"suggested letter is: %@",temp.letter]);
    }

}

@end
