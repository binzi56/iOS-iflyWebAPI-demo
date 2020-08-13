//
//  UIControl+BtnQuickLimit.m
//  AFNetworking
//
//  Created by DF on 2018/12/12.
//

#import "UIControl+BtnQuickLimit.h"
#import <objc/runtime.h>
#import "HYLogMacros.h"

static const char * UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char * UIControl_ignoreEvent = "UIControl_ignoreEvent";

@implementation UIControl (BtnQuickLimit)

-(void)setAcceptEventInterval:(double)acceptEventInterval {
    //关联属性对象
    objc_setAssociatedObject(self, UIControl_acceptEventInterval,@(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)acceptEventInterval{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

-(void)setIgnoreEvent:(BOOL)ignoreEvent {
    //关联属性对象
    objc_setAssociatedObject(self, UIControl_ignoreEvent, @(ignoreEvent), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)ignoreEvent{
    return [objc_getAssociatedObject(self, UIControl_ignoreEvent) boolValue];
}

+(void)load{
    Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self, @selector(swizzing_sendAction:to:forEvent:));
    method_exchangeImplementations(a, b);
}

-(void)swizzing_sendAction:(SEL)action to:(id)tagert forEvent:(UIEvent*)event{
    if (self.ignoreEvent) {
        DYLogInfo(@"你点击的太快了");
        return;
    }
    if (self.acceptEventInterval>0) {
        self.ignoreEvent = YES;
        [self performSelector:@selector(setIgnoreWithNo) withObject:nil afterDelay:self.acceptEventInterval];
    } 
    [self swizzing_sendAction:action to:tagert forEvent:event];
}
-(void)setIgnoreWithNo{
    self.ignoreEvent = NO;
}

@end
