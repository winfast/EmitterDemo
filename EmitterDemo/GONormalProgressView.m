//
//  GONormalProgressView.m
//  EmitterDemo
//
//  Created by QinChuancheng on 2020/7/4.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import "GONormalProgressView.h"


@interface GONormalProgressView ()

@property (nonatomic, strong) GOProgressConfig *config;

@property (strong, nonatomic) UIView *progressContent;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) UIBezierPath *progressPath;
@property (assign, nonatomic) CGFloat progress;


//下面的数据是用来支持进度变色的属性
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, assign) CGFloat animationFromValue;
@property (nonatomic, assign) CGFloat animationToValue;
@property (nonatomic, assign) CGFloat realTimeProgress;
@property (nonatomic) CGFloat animationduration;

@end

@implementation GONormalProgressView

- (instancetype)initWithFrame:(CGRect)frame config:(GOProgressConfig *)config {
	if (self = [super initWithFrame:frame]) {
		self.config = config;
		
		self.clipsToBounds = NO;
		
		self.progressContent = [UIView.alloc initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
		self.progressContent.backgroundColor = [UIColor clearColor];
		self.progressContent.layer.cornerRadius = self.progressContent.frame.size.width * 0.5;
		self.progressContent.layer.masksToBounds = YES;
		self.progressContent.clipsToBounds = NO;
		[self addSubview:self.progressContent];
		
		self.innerShadowLayer = CALayer.layer;
		self.innerShadowLayer.frame = CGRectMake(self.config.progressLineWidth - 2, self.config.progressLineWidth - 2, self.progressContent.bounds.size.width - self.config.progressLineWidth * 2 + 2 * 2, self.progressContent.bounds.size.width - self.config.progressLineWidth * 2 + 2 * 2);
		self.innerShadowLayer.backgroundColor = self.config.innerColors ? self.config.innerColors.firstObject.CGColor : [UIColor colorWithRed:207/255.0 green:128/255.0 blue:0 alpha:1].CGColor;
		
		CALayer *contentLayer = CALayer.layer;
		contentLayer.frame = self.innerShadowLayer.bounds;
		contentLayer.contents = (id)[UIImage imageNamed:@"common_floating_inner"].CGImage;
		contentLayer.contentsScale = [UIScreen mainScreen].scale;
		[self.innerShadowLayer setMask:contentLayer];
		[self.progressContent.layer addSublayer:self.innerShadowLayer];
		
        self.borderLayer = CALayer.layer;
		self.borderLayer.frame = self.progressContent.bounds;
		self.borderLayer.cornerRadius = self.progressContent.bounds.size.width * 0.5;
		self.borderLayer.borderWidth = self.config.progressLineWidth;
		self.borderLayer.borderColor = self.config.progressColors ? self.config.progressColors.firstObject.CGColor : [UIColor colorWithRed:1.0 green:93/255.0 blue:0 alpha:1].CGColor;
        [self.progressContent.layer addSublayer:self.borderLayer];
		
		//绘制进度
		self.progressPath = [UIBezierPath bezierPathWithArcCenter:self.progressContent.center radius:self.progressContent.bounds.size.width * 0.5 * 0.5 startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        self.progressLayer = [CAShapeLayer layer];
		self.progressLayer.frame = self.progressContent.bounds;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = UIColor.blackColor.CGColor;
		self.progressLayer.lineWidth = self.progressContent.bounds.size.width * 0.5;
        self.progressLayer.path = self.progressPath.CGPath;
		self.progressContent.layer.mask = self.progressLayer;
		self.progressLayer.strokeEnd = 0.0;
//
		self.circleLayer = [CALayer layer];
		self.circleLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
		self.circleLayer.borderWidth = self.config.backgroundProgressLineWitdh;
		self.circleLayer.cornerRadius = self.circleLayer.frame.size.width * 0.5;
		self.circleLayer.borderColor = self.config.backgroundProgressLineColor ? self.config.backgroundProgressLineColor.CGColor : [UIColor.whiteColor colorWithAlphaComponent:0.1].CGColor;
		[self.layer insertSublayer:self.circleLayer below:self.progressContent.layer];

		if (self.config.isRotate) {
			self.progress = 1;
			self.progressLayer.strokeEnd = 1;
			self.rotateLayer = [CAGradientLayer layer];
			self.rotateLayer.frame = self.bounds;
			__block NSMutableArray *colors = NSMutableArray.alloc.init;
			[self.config.gradientLayerColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				if (obj) {
					[colors addObject:obj.CGColor];
				}
			}];
			((CAGradientLayer *)self.rotateLayer).colors = colors;
			((CAGradientLayer *)self.rotateLayer).startPoint = CGPointMake(1, 1);
			((CAGradientLayer *)self.rotateLayer).endPoint = CGPointMake(0, 0);
			//hypot 获取直角三角形的边长
			CGFloat lenth = hypot(self.progressLayer.bounds.size.width, self.progressLayer.bounds.size.width);
			((CAGradientLayer *)self.rotateLayer).locations = [NSArray arrayWithObjects:@(0.5),@((lenth * 0.5 + self.bounds.size.width * 0.5)/lenth),nil];
			[self.progressContent.layer addSublayer:self.rotateLayer];
			
			CALayer *rotateMaskLayer = CALayer.layer;
			rotateMaskLayer.frame = self.rotateLayer.bounds;
			rotateMaskLayer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor;
			rotateMaskLayer.borderColor = UIColor.whiteColor.CGColor;
			rotateMaskLayer.borderWidth = self.config.progressLineWidth;
			rotateMaskLayer.cornerRadius = self.rotateLayer.frame.size.width * 0.5;
			rotateMaskLayer.masksToBounds = YES;
			((CAGradientLayer *)self.rotateLayer).mask = rotateMaskLayer;
		}
	}
	return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration {
	if (self.config.isRotate) {
		return;
	}

	if (self.progress == progress) {
		return;
	}
	
	if (self.config.isUpdateColor) {
		if (self.displayLink) {
			[self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
			[self.displayLink invalidate];
			self.displayLink = nil;
		}
		
		self.animationduration = duration;
		self.animationStartTime = CACurrentMediaTime();
		self.animationFromValue = self.progress;
		self.animationToValue = progress;
		self.realTimeProgress = 0.0;
		self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
		[self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
	}
	else {
		CABasicAnimation *strokeEnd = CABasicAnimation.animation;
		strokeEnd.keyPath = @"strokeEnd";
		strokeEnd.duration = 1;
		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		strokeEnd.fromValue = @(self.progress);
		strokeEnd.toValue = @(progress);
		strokeEnd.fillMode = kCAFillModeForwards;
		strokeEnd.removedOnCompletion = NO;
		[self.progressLayer addAnimation:strokeEnd forKey:nil];
		
		self.progress = progress;
	}
}

- (void)animateProgress:(CADisplayLink *)displayLink {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.animationduration == 0) {
			self.animationduration = 1;
		}
		CGFloat dt = (self.displayLink.timestamp - self.animationStartTime) / self.animationduration;
		if (dt >= self.animationduration) {
			[self.displayLink invalidate];
			self.displayLink = nil;
		}
		self.realTimeProgress = self.animationFromValue + dt * (self.animationToValue - self.animationFromValue);

		NSInteger endColorIndex = 0;
		NSInteger locationCount = self.config.locations.count;
		for (NSInteger currIndex = locationCount - 1; currIndex >= 0; --currIndex) {
			CGFloat currLocation = self.config.locations[currIndex].doubleValue;
			if (self.realTimeProgress > currLocation) {
				endColorIndex = currIndex + 1;
				break;
			}  else	if (self.realTimeProgress > currLocation) {
				endColorIndex = currIndex + 1;
				break;
			} else if (self.realTimeProgress > currLocation) {
				endColorIndex = currIndex + 1;
				break;
			} else if (self.realTimeProgress > currLocation) {
				endColorIndex = currIndex + 1;
				break;
			} else if (self.realTimeProgress > currLocation) {
				endColorIndex = currIndex + 1;
				break;
			}
		}
		
//		if (self.realTimeProgress > self.config.locations[4].doubleValue) {
//			endColorIndex = 5;
//		}  else	if (self.realTimeProgress > self.config.locations[3].doubleValue) {
//			endColorIndex = 4;
//		} else if (self.realTimeProgress > self.config.locations[2].doubleValue) {
//			endColorIndex = 3;
//		} else if (self.realTimeProgress > self.config.locations[1].doubleValue) {
//			endColorIndex = 2;
//		} else if (self.realTimeProgress > self.config.locations[0].doubleValue) {
//			endColorIndex = 1;
//		}
		
		UIColor *endInnerColor = self.config.innerColors[endColorIndex];
		UIColor *endProgressColor =  self.config.progressColors[endColorIndex];
		if (0 == endColorIndex || locationCount == endColorIndex) {
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			self.borderLayer.borderColor = endProgressColor.CGColor;
			self.innerShadowLayer.backgroundColor = endInnerColor.CGColor;
			[CATransaction commit];
		} else {
			UIColor *startInnerColor = self.config.innerColors[endColorIndex - 1];
			UIColor *startProgressColor = self.config.progressColors[endColorIndex - 1];

			CGFloat ratio = (self.realTimeProgress - self.config.locations[endColorIndex - 1].doubleValue)/( self.config.locations[endColorIndex].doubleValue -  self.config.locations[endColorIndex - 1].doubleValue);
			UIColor *currInnerColor = [GONormalProgressView mixColor1:startInnerColor color2:endInnerColor ratio:ratio];
			UIColor *currProgressColor = [GONormalProgressView mixColor1:startProgressColor color2:endProgressColor ratio:ratio];
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			self.borderLayer.borderColor = currProgressColor.CGColor;
			self.innerShadowLayer.backgroundColor = currInnerColor.CGColor;
			[CATransaction commit];
		}

		CABasicAnimation *strokeEnd = CABasicAnimation.animation;
		strokeEnd.keyPath = @"strokeEnd";
		strokeEnd.duration = self.displayLink.duration;
		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		strokeEnd.fromValue = @(self.progress);
		strokeEnd.toValue = @(self.realTimeProgress);
		strokeEnd.fillMode = kCAFillModeForwards;
		strokeEnd.removedOnCompletion = NO;
		strokeEnd.autoreverses = NO;
		[self.progressLayer addAnimation:strokeEnd forKey:nil];
		self.progress = self.realTimeProgress;
	});
}

//混色
+ (UIColor *)mixColor1:(UIColor*)color1 color2:(UIColor *)color2 ratio:(CGFloat)ratio
{
    if(ratio > 1)
        ratio = 1;
    const CGFloat * components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat * components2 = CGColorGetComponents(color2.CGColor);
    CGFloat r = components2[0]*ratio + components1[0]*(1-ratio);
    CGFloat g = components2[1]*ratio + components1[1]*(1-ratio);
    CGFloat b = components2[2]*ratio + components1[2]*(1-ratio);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
