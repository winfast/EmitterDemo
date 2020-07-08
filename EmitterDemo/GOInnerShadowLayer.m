//
//  GOInnerShadowLayer.m
//  EmitterDemo
//
//  Created by QinChuancheng on 2020/7/4.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import "GOInnerShadowLayer.h"


@interface GOInnerShadowLayer ()

@end

@implementation GOInnerShadowLayer

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers]; /// 异步执行、处理子视图数据
    [self setNeedsDisplay];  /// 异步执行、自动调用drawInContext绘图方法
}

//- (void)drawInContext:(CGContextRef)context {
//
//	// 初始设置
//	CGContextSetAllowsAntialiasing(context, YES);// 反锯齿
//	CGContextSetShouldAntialias(context, YES);
//	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);// 画面质量
//
//	// 设置内阴影路径
//	CGRect rect = self.bounds;
//	if (self.borderWidth != 0) {
//		rect = CGRectInset(rect, self.borderWidth, self.borderWidth);
//	}
//
//	CGContextAddPath(context, self.go_shadowPath.CGPath);
//	CGContextClip(context);
//
//	CGMutablePathRef outer = CGPathCreateMutable();
//	CGPathAddRect(outer, NULL, CGRectInset(rect, -1 * rect.size.width, -1 * rect.size.height));
//
//	CGPathAddPath(outer, NULL, self.go_shadowPath.CGPath);
//	CGPathCloseSubpath(outer);
//
//	// 开始绘制内阴影
//	CGContextSetAlpha(context, self.go_shadowOpacity);
//	CGContextSetFillColorWithColor(context, self.go_shadowColor.CGColor);
//	CGContextSetShadowWithColor(context, self.go_shadowOffset, self.go_shadowRadius, self.go_shadowColor.CGColor);
//	CGContextSetBlendMode(context, kCGBlendModeSourceOut);
//
//	CGContextAddPath(context, outer);
//	CGContextEOFillPath(context);
//	CGPathRelease(outer);
//	return;
//
////	UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0];
//////	NSShadow *shadow2 = [[NSShadow alloc] init];
//////	shadow2.shadowColor = UIColor.redColor;
//////	shadow2.shadowOffset = CGSizeMake(0, 0);
//////	shadow2.shadowBlurRadius = 25;
////
////	[color setFill];
////	[self.go_shadowPath fill];
////
////	CGContextSaveGState(ctx);
////	CGContextClipToRect(ctx, self.go_shadowPath.bounds);
////	CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
////	CGContextSetAlpha(ctx, self.go_shadowOpacity);
////
////	CGContextBeginTransparencyLayer(ctx, NULL);
////	CGContextSetShadowWithColor(ctx, self.go_shadowOffset, self.go_shadowRadius, self.go_shadowColor.CGColor);
////	CGContextSetBlendMode(ctx, kCGBlendModeSourceOut);
////	CGContextBeginTransparencyLayer(ctx, NULL);
////
////	[self.go_shadowColor setFill];
////	[self.go_shadowPath fill];
////	CGContextEndTransparencyLayer(ctx);
////	CGContextEndTransparencyLayer(ctx);
////	CGContextRestoreGState(ctx);
//}

#pragma mark - 绘制内阴影 -
- (void)drawInContext:(CGContextRef)context {
    // 初始设置
    CGContextSetAllowsAntialiasing(context, YES);// 反锯齿
    CGContextSetShouldAntialias(context, YES);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);// 画面质量
    // 设置内阴影路径
    CGRect rect = self.bounds;
    if (self.borderWidth != 0) {
        rect = CGRectInset(rect, self.borderWidth, self.borderWidth);
    }
    CGContextAddPath(context, self.go_shadowPath.CGPath);
    CGContextClip(context);

    CGMutablePathRef outer = CGPathCreateMutable();
    CGPathAddRect(outer, NULL, CGRectInset(rect, -1 * rect.size.width, -1 * rect.size.height));

    CGPathAddPath(outer, NULL, self.go_shadowPath.CGPath);
    CGPathCloseSubpath(outer);

    // 开始绘制内阴影
	CGContextSetAlpha(context, self.go_shadowOpacity);
	CGContextSetFillColorWithColor(context, self.go_shadowColor.CGColor);
    CGContextSetShadowWithColor(context, self.go_shadowOffset, self.go_shadowRadius, self.go_shadowColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceOut);
    CGContextAddPath(context, outer);
    CGContextEOFillPath(context);

    CGPathRelease(outer);
}

- (void)setGo_shadowColor:(UIColor *)go_shadowColor {
	_go_shadowColor = go_shadowColor;
	[self setNeedsDisplay];
}

@end
