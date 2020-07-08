//
//  UIViewController+KLTraceLog.m
//  KLExtensions
//
//  Created by Logic on 2019/11/20.
//

#import "UIViewController+KLTraceLog.h"
#import "NSLogger.h"
#import "NSObject+UIKit.h"
#import "NSRuntime.h"

@implementation UIViewController (KLTraceLog)

#ifdef DEBUG

+ (void)load {
    KLExchangeImplementations(self, @selector(viewDidLoad), self, @selector(kl_viewDidLoad));
    KLExchangeImplementations(self, NSSelectorFromString(@"dealloc"), self, @selector(kl_dealloc));
}

- (void)kl_viewDidLoad {
    if (KLViewControllerTraceLogEnableState()) {
        NSLogNotice(@"%@ viewDidLoad", self);
    }
    [self kl_viewDidLoad];
}

- (void)kl_dealloc {
    if (KLViewControllerTraceLogEnableState()) {
        NSLogNotice(@"%@ dealloc", self);
    }
    [self kl_dealloc];
}

#endif

@end
