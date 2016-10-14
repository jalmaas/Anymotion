//
// Authors: Mats Hauge <mats@agens.no>
//          Håvard Fossli <hfossli@agens.no>
//
// Copyright (c) 2013 Agens AS (http://agens.no/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ANYCAKeyframeAnimation.h"
#import "ANYEXTScope.h"
#import "ANYCALayerAnimationBlockDelegate.h"


@interface ANYCAKeyframeAnimation ()
@property (nonatomic, copy) void (^configure)(CAKeyframeAnimation *anim);
@property (nonatomic, assign) BOOL shouldUpdateModel;

@end

@implementation ANYCAKeyframeAnimation

+ (instancetype)keyPath:(NSString *)keyPath
{
    return [[self new] configure:^(CAKeyframeAnimation *anim) {
        anim.keyPath = keyPath;
    }];
}

- (instancetype)configure:(void (^)(CAKeyframeAnimation *anim))configure
{
    ANYCAKeyframeAnimation *instance = [ANYCAKeyframeAnimation new];
    instance.configure = ^(CAKeyframeAnimation *basic){
        if(self.configure)
        {
            self.configure(basic);
        }
        if(configure)
        {
            configure(basic);
        }
    };
    instance.shouldUpdateModel = self.shouldUpdateModel;
    return instance;
}

- (CAKeyframeAnimation *)build
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    self.configure(anim);
    return anim;
}

- (instancetype)values:(NSArray *)values
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.values = values;
    }];
}

- (instancetype)path:(CGPathRef)path
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.path = path;
    }];
}

- (instancetype)keyTimes:(NSArray<NSNumber *> *)keyTimes
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.keyTimes = keyTimes;
    }];
}

- (instancetype)timingFunctions:(NSArray<CAMediaTimingFunction *> *)timingFunctions
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.timingFunctions = timingFunctions;
    }];
}

- (instancetype)calculationMode:(NSString *)calculationMode
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.calculationMode = calculationMode;
    }];
}

- (instancetype)tensionValues:(NSArray<NSNumber *> *)tensionValues
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.tensionValues = tensionValues;
    }];
}

- (instancetype)continuityValues:(NSArray<NSNumber *> *)continuityValues
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.continuityValues = continuityValues;
    }];
}

- (instancetype)biasValues:(NSArray<NSNumber *> *)biasValues
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.biasValues = biasValues;
    }];
}

- (instancetype)rotationMode:(NSString *)rotationMode
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.rotationMode = rotationMode;
    }];
}

- (instancetype)duration:(NSTimeInterval)duration
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.duration = duration;
    }];
}

- (instancetype)additive:(BOOL)additive
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.additive = additive;
    }];
}

- (instancetype)cumulative:(BOOL)cumulative
{
    return [self configure:^(CAKeyframeAnimation *anim) {
        anim.cumulative = cumulative;
    }];
}

- (ANYAnimation *)animationFor:(CALayer *)layer
{
    
    @weakify(layer);
    return [ANYAnimation createAnimation:^ANYActivity *(ANYSubscriber *subscriber) {
        @strongify(layer);
        
        CAKeyframeAnimation *basic = [self build];
        NSAssert(basic.keyPath.length > 0, @"Missing keypath. Did you construct using +[%@ %@]?", NSStringFromClass([self class]), NSStringFromSelector(@selector(keyPath:)));
        
        basic.delegate = [ANYCALayerAnimationBlockDelegate newWithAnimationDidStop:^(BOOL completed){
            if(completed)
            {
                [subscriber completed];
            }
            else
            {
                [subscriber failed];
            }
        }];
        
        NSString *key = [NSString stringWithFormat:@"any.%@", basic.keyPath];
        [layer removeAnimationForKey:key];
        [layer addAnimation:basic forKey:key];
        
        return [[ANYActivity activityWithTearDownBlock:^{
            
            @strongify(layer);
            [layer removeAnimationForKey:key];
            
        }] nameFormat:@"(CA.keyframe key: '%@', layer '<%@ %p>')", basic.keyPath, layer.class, layer];
        
    }];
}

@end
