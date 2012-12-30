/***********************************************************************************
 *
 * Copyright (c) 2012 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/


#import "AsyncSenTestCase.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface AsyncSenTestCase()
@property(atomic, assign) NSUInteger asyncTestCaseSignaledCount;
@end

@implementation AsyncSenTestCase
@synthesize asyncTestCaseSignaledCount = _asyncTestCaseSignaledCount;

-(void)waitForAsyncOperationWithTimeout:(NSTimeInterval)timeout
{
    [self waitForAsyncOperations:1 withTimeout:timeout];
}

-(void)waitForAsyncOperations:(NSUInteger)count withTimeout:(NSTimeInterval)timeout
{
    static const NSTimeInterval kSamplingInterval = 0.05;
    
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while ((self.asyncTestCaseSignaledCount < count) && ([timeoutDate timeIntervalSinceNow]>0))
    {
        if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:kSamplingInterval]])
        {
            // If the RunLoop cannot be started (or there is no runloop installed in the current thread), sleep for some time (to avoid 100% CPU polling)
            [NSThread sleepForTimeInterval:kSamplingInterval];
        }
    }
    
    if ([timeoutDate timeIntervalSinceNow]<0)
    {
        // now is after timeoutDate, we timed out
        STFail(@"Timed out while waiting for Async Operations to finish.");
    }
}

-(void)waitForTimeout:(NSTimeInterval)timeout
{
    static const NSTimeInterval kSamplingInterval = 0.05;
    
    NSDate* waitEndDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while ([waitEndDate timeIntervalSinceNow]>0)
    {
        if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:kSamplingInterval]])
        {
            // If the RunLoop cannot be started (or there is no runloop installed in the current thread), sleep for some time (to avoid 100% CPU polling)
            [NSThread sleepForTimeInterval:kSamplingInterval];
        }
    }
}

-(void)notifyAsyncOperationDone
{
    @synchronized(self)
    {
        self.asyncTestCaseSignaledCount = self.asyncTestCaseSignaledCount+1;
    }
}

@end
