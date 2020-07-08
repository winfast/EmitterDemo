//
//  EmitterCircleProgress.m
//  EmitterDemo
//
//  Created by Logic on 2020/5/23.
//  Copyright © 2020 caohouhong. All rights reserved.
//

//取消隐式动画
/*
 [CATransaction begin];
 [CATransaction setDisableActions:YES];
 self.myview.layer.position= CGPointMake(10, 10);
 [CATransaction commit];
 */

#import "GOEmitterCircleProgress.h"


#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

@interface GOEmitterCircleProgress ()

@property (nonatomic, strong) GOProgressConfig *config;

//粒子的View
@property (nonatomic, strong) UIView *emitterView;

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

@implementation GOEmitterCircleProgress

- (instancetype)initWithFrame:(CGRect)frame config:(nonnull GOProgressConfig *)config
{
    self = [super initWithFrame:frame];
    if (self) {
		self.config = config;

        self.progressContent = [UIView.alloc initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [self addSubview:self.progressContent];
		
		CGFloat startX = self.config.needleCircleRadius - self.config.progressCircleRadius;
		UIView *outerShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
		outerShadowView.backgroundColor = [UIColor clearColor];
		outerShadowView.layer.cornerRadius = outerShadowView.frame.size.width * 0.5;
		outerShadowView.layer.masksToBounds = YES;
		outerShadowView.clipsToBounds = NO;
		[self.progressContent addSubview:outerShadowView];

		//添加外发光  默认FF1600颜色
		UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(outerShadowView.bounds.size.width * 0.5, outerShadowView.bounds.size.width * 0.5) radius:outerShadowView.bounds.size.width * 0.5 - startX - 1 startAngle:0 endAngle:2*M_PI clockwise:YES];
		KJShadowLayer *outerShodowLayer = [[KJShadowLayer alloc] kj_initWithFrame:outerShadowView.bounds ShadowType:KJShadowTypeOuterShine];
		outerShodowLayer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor;
		outerShodowLayer.kj_shadowPath = path1;
		outerShodowLayer.kj_shadowColor = self.config.outerColors ? self.config.outerColors.firstObject : [UIColor colorWithRed:1.0 green:22/255.0 blue:0 alpha:1];
		outerShodowLayer.kj_shadowOpacity = 0.5;
		outerShodowLayer.kj_shadowDiffuse = 0;
		outerShodowLayer.kj_shadowRadius = self.config.outerShadowRadius;
		outerShodowLayer.kj_shadowOffset = CGSizeZero;
		[outerShadowView.layer addSublayer:outerShodowLayer];
		self.outerShadowLayer = outerShodowLayer;
		
		self.emitterView = [[UIView alloc] initWithFrame:CGRectMake(startX, startX, frame.size.width - startX * 2, frame.size.width - startX * 2)];
        self.emitterView.backgroundColor = [UIColor clearColor];
		self.emitterView.layer.cornerRadius = self.emitterView.frame.size.width * 0.5;
        self.emitterView.layer.masksToBounds = YES;
        [self.progressContent addSubview:self.emitterView];
		
        /*layer层有隐式动画（默认自动调用的动画效果）
        我们通过切换layer层的背景颜色来验证
        结论：每次切换颜色都有一个渐变的动画效果，在UIView是不会触发这种效果的*/
//		UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.emitterView.bounds.size.width * 0.5, self.emitterView.bounds.size.width * 0.5) radius:self.emitterView.bounds.size.width * 0.5 - self.config.progressLineWidth + 1 startAngle:0 endAngle:2*M_PI clockwise:YES];
//        GOInnerShadowLayer *innerShodowLayer = [GOInnerShadowLayer layer];
//		innerShodowLayer.frame = self.emitterView.bounds;
//        innerShodowLayer.go_shadowPath = path;
//		innerShodowLayer.go_shadowColor = self.config.innerShadowColor ?: [UIColor colorWithRed:1.0 green:24/255.0 blue:50/255.0 alpha:0.6];
//		innerShodowLayer.go_shadowOpacity = 1;
//		innerShodowLayer.go_shadowRadius = self.config.innerShadowRadius;
//        innerShodowLayer.go_shadowOffset = CGSizeZero;
//        [self.emitterView.layer addSublayer:innerShodowLayer];
//        self.innerShadowLayer = innerShodowLayer;
		
		//由于内阴影的渐变效果不符合设计部门的需求, 所以使用图片的方式添加渐变,原理是图层+mask  默认CF1C00
		self.innerShadowLayer = CALayer.layer;
		self.innerShadowLayer.frame = CGRectMake(self.config.progressLineWidth - 1, self.config.progressLineWidth - 1, self.emitterView.bounds.size.width - self.config.progressLineWidth * 2 + 2, self.emitterView.bounds.size.width - self.config.progressLineWidth * 2 + 2);
		self.innerShadowLayer.backgroundColor = self.config.innerColors ? self.config.innerColors.firstObject.CGColor : [UIColor colorWithRed:207/255.0 green:128/255.0 blue:0 alpha:1].CGColor;
		CALayer *contentLayer = CALayer.layer;
		contentLayer.frame = self.innerShadowLayer.bounds;
		contentLayer.contentsScale = [UIScreen mainScreen].scale;
		contentLayer.contents = (id)[UIImage imageNamed:@"common_circle_inner"].CGImage;
		[self.innerShadowLayer setMask:contentLayer];
		[self.emitterView.layer addSublayer:self.innerShadowLayer];
	
		CAEmitterCell *cell = [[CAEmitterCell alloc] init];
		//展示的图片
		cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"white"].CGImage);
		//cell.contentsScale = [UIScreen mainScreen].scale;
		//每秒粒子产生个数的乘数因子，会和layer的birthRate相乘，然后确定每秒产生的粒子个数
		cell.birthRate = 80;
		
		//每个粒子存活时长
		cell.lifetime = 3;
		//粒子透明度变化，设置为－0.35，就是每过一秒透明度就减少0.25，这样就有消失的效果,一般设置为负数。
		cell.alphaSpeed = -0.35;
		cell.alphaRange = 0.2;
		
		//粒子生命周期范围
		cell.lifetimeRange = 0.1;
		//粒子的速度
		cell.velocity = 20;
		//粒子的速度范围
		cell.velocityRange = 20;
		//粒子内容的颜色
		//cell.color = UIColor.whiteColor.CGColor;
		//缩放比例
		cell.scale = 0.25;
		//缩放比例范围
		cell.scaleSpeed = -0.1;
		cell.scaleRange = 0.2;
		cell.emissionLongitude = M_PI; // 向左
		cell.emissionRange = M_PI_4; // 围绕X轴向左90度
		
		_emitterLayer = [CAEmitterLayer layer];
		_emitterLayer.position = CGPointMake(0, self.emitterView.bounds.size.width * 0.5);
		_emitterLayer.backgroundColor = UIColor.whiteColor.CGColor;
		//发射位置
		_emitterLayer.emitterPosition = CGPointMake(self.emitterView.bounds.size.width * 0.5, 0);
		//粒子产生系数，默认为1
		_emitterLayer.birthRate = 1;
		//发射器的尺寸
		_emitterLayer.emitterSize = CGSizeMake(self.emitterView.bounds.size.width, 0);
		//发射的形状
		_emitterLayer.emitterShape = kCAEmitterLayerCircle;
		//发射的模式
		_emitterLayer.emitterMode = kCAEmitterLayerOutline;
		//渲染模式
		_emitterLayer.renderMode = kCAEmitterLayerUnordered;
		
		_emitterLayer.zPosition = -1;
		_emitterLayer.emitterCells = @[cell];
		//[self.emitterView.layer addSublayer:_emitterLayer];
		
		//通过mask修改粒子的颜色  默认FF5500
		self.emitterColorLayer = CALayer.layer;
		self.emitterColorLayer.frame = self.emitterView.bounds;
		self.emitterColorLayer.backgroundColor = self.config.emitterColors ? self.config.emitterColors.firstObject.CGColor : [UIColor colorWithRed:1.0 green:85/255.0 blue:0 alpha:1].CGColor;
		[self.emitterView.layer addSublayer:self.emitterColorLayer];
		[self.emitterColorLayer setMask:self.emitterLayer];
	
		//绘制外面的满进度layer FF5D00
        self.borderLayer = CALayer.layer;
		self.borderLayer.frame = CGRectMake(startX, startX, frame.size.width - startX * 2 , frame.size.width - startX * 2);
		self.borderLayer.cornerRadius = self.borderLayer.frame.size.width * 0.5;
		self.borderLayer.borderWidth = self.config.progressLineWidth;
		self.borderLayer.borderColor = self.config.progressColors ? self.config.progressColors.firstObject.CGColor : [UIColor colorWithRed:1.0 green:93/255.0 blue:0 alpha:1].CGColor;
        [self.progressContent.layer addSublayer:self.borderLayer];
        
		//绘制进度
		self.progressPath = [UIBezierPath bezierPathWithArcCenter:self.progressContent.center radius:self.progressContent.bounds.size.width * 0.5 * 0.5 startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        self.progressLayer = [CAShapeLayer layer];
		self.progressLayer.frame = self.emitterView.bounds;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = UIColor.blackColor.CGColor;
		self.progressLayer.lineWidth = self.emitterView.bounds.size.width * 0.5;
        self.progressLayer.path = self.progressPath.CGPath;
		self.progressContent.layer.mask = self.progressLayer;
		self.progressLayer.strokeEnd = 0.0;
		
		CGFloat distance = self.config.progressLineWidth - self.config.backgroundProgressLineWitdh;
		self.circleLayer = [CALayer layer];
		self.circleLayer.frame = CGRectMake(startX - distance * 0.5, startX - distance * 0.5, frame.size.width - startX * 2 - distance, frame.size.width - startX * 2 - distance);
		self.circleLayer.borderWidth = self.config.backgroundProgressLineWitdh;
		self.circleLayer.cornerRadius = self.circleLayer.frame.size.width * 0.5;
		self.circleLayer.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.0].CGColor;
		self.circleLayer.borderColor = self.config.backgroundProgressLineColor ? self.config.backgroundProgressLineColor.CGColor : [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
		[self.layer insertSublayer:self.circleLayer below:self.progressContent.layer];
		
		if (self.config.isShowNeedle) {
			self.lineLayer = [[GOLayer alloc] initWithFrame:CGRectMake(2, 2, self.bounds.size.width - 4, self.bounds.size.width - 4)];
			self.lineLayer.backgroundColor = self.config.needleColors ? self.config.needleColors.firstObject.CGColor : [UIColor colorWithRed:1.0 green:173/255.0 blue:0 alpha:0].CGColor;
			[self.layer addSublayer:self.lineLayer];
		}
		else {
			//通过渐变实现颜色变化
			self.progressLayer.strokeEnd = 1;
			self.lineLayer = [CAGradientLayer layer];
			self.lineLayer.frame = CGRectMake(startX, startX, frame.size.width - startX * 2, frame.size.width - startX * 2);
			__block NSMutableArray *colors = NSMutableArray.alloc.init;
			[self.config.gradientLayerColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				if (obj) {
					[colors addObject:obj.CGColor];
				}
			}];
			((CAGradientLayer *)self.lineLayer).colors = colors;
			((CAGradientLayer *)self.lineLayer).startPoint = CGPointMake(0, 1);
			((CAGradientLayer *)self.lineLayer).endPoint = CGPointMake(0, 0);
			((CAGradientLayer *)self.lineLayer).locations = [NSArray arrayWithObjects:@(0.75),@(1),nil];
			[self.layer addSublayer:self.lineLayer];
			
			CALayer *rotateMaskLayer = CALayer.layer;
			rotateMaskLayer.frame = self.lineLayer.bounds;
			rotateMaskLayer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor;
			rotateMaskLayer.borderColor = UIColor.whiteColor.CGColor;
			rotateMaskLayer.borderWidth = self.config.progressLineWidth;
			rotateMaskLayer.cornerRadius = self.lineLayer.frame.size.width * 0.5;
			rotateMaskLayer.masksToBounds = YES;
			((CAGradientLayer *)self.lineLayer).mask = rotateMaskLayer;
		}

        self.numberView = [FFDynamicNumberView new];
        self.numberView.frame = CGRectMake(0, 0, 200, 200);
        self.numberView.center = self.progressContent.center;
        self.numberView.backgroundColor = UIColor.clearColor;
        self.numberView.numberColor = UIColor.whiteColor;
        self.numberView.numberBackColor = UIColor.clearColor;
        self.numberView.numberCount = 1;
        self.numberView.numberSpace = 0;
		self.numberView.numberFont = self.config.numberFont ?: [UIFont systemFontOfSize:80];
        self.numberView.numberAlignment = NumberAlignmentCenter;
        [self addSubview:self.numberView];

    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration {	
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
		strokeEnd.duration = duration;
		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		strokeEnd.fromValue = @(self.progress);
		strokeEnd.toValue = @(progress);
		strokeEnd.fillMode = kCAFillModeForwards;
		strokeEnd.removedOnCompletion = NO;
		[self.progressLayer addAnimation:strokeEnd forKey:nil];
		
		if (self.config.isShowNeedle) {
			CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
			rotateAnimation.fromValue = @(self.progress * M_PI * 2);
			rotateAnimation.toValue = @(progress * M_PI * 2);
			rotateAnimation.duration = duration;
			rotateAnimation.fillMode = kCAFillModeForwards;
			rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			rotateAnimation.removedOnCompletion = NO; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
			[self.lineLayer addAnimation:rotateAnimation forKey:@"rotation"];
		}
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
		UIColor *endEmiterColor =  self.config.emitterColors[endColorIndex];
		UIColor *endOuterColor =  self.config.outerColors[endColorIndex];
		UIColor *endProgressColor =  self.config.progressColors[endColorIndex];
		UIColor *endNeedleColor =  self.config.needleColors[endColorIndex];

		if (0 == endColorIndex || locationCount == endColorIndex) {
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			self.emitterColorLayer.backgroundColor = endEmiterColor.CGColor;
			self.borderLayer.borderColor = endProgressColor.CGColor;
			self.innerShadowLayer.backgroundColor = endInnerColor.CGColor;
			self.lineLayer.backgroundColor = endNeedleColor.CGColor;
			self.outerShadowLayer.kj_shadowColor = endOuterColor;
			[CATransaction commit];
		} else {
			UIColor *startInnerColor = self.config.innerColors[endColorIndex - 1];
			UIColor *startEmiterColor =  self.config.emitterColors[endColorIndex - 1];
			UIColor *startOuterColor =  self.config.outerColors[endColorIndex - 1];
			UIColor *startProgressColor = self.config.progressColors[endColorIndex - 1];
			UIColor *startNeedleColor = self.config.needleColors[endColorIndex - 1];

			CGFloat ratio = (self.realTimeProgress - self.config.locations[endColorIndex - 1].doubleValue)/( self.config.locations[endColorIndex].doubleValue -  self.config.locations[endColorIndex - 1].doubleValue);
			UIColor *currInnerColor = [GOEmitterCircleProgress mixColor1:startInnerColor color2:endInnerColor ratio:ratio];
			UIColor *currEmiterColor = [GOEmitterCircleProgress mixColor1:startEmiterColor color2:endEmiterColor ratio:ratio];
			UIColor *currOuterColor = [GOEmitterCircleProgress mixColor1:startOuterColor color2:endOuterColor ratio:ratio];
			UIColor *currProgressColor = [GOEmitterCircleProgress mixColor1:startProgressColor color2:endProgressColor ratio:ratio];
			UIColor *currNeedleColor = [GOEmitterCircleProgress mixColor1:startNeedleColor color2:endNeedleColor ratio:ratio];

			self.emitterColorLayer.backgroundColor = currEmiterColor.CGColor;
			self.borderLayer.borderColor = currProgressColor.CGColor;
			self.innerShadowLayer.backgroundColor = currInnerColor.CGColor;
			self.lineLayer.backgroundColor = currNeedleColor.CGColor;
			self.outerShadowLayer.kj_shadowColor = currOuterColor;
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

		CABasicAnimation *transform = CABasicAnimation.animation;
		transform.keyPath = @"transform.rotation.z";
		transform.duration = self.displayLink.duration;
		transform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		transform.fromValue = @(M_PI * 2 * self.progress);
		transform.toValue = @(M_PI * 2 * self.realTimeProgress);
		transform.fillMode = kCAFillModeForwards;
		transform.removedOnCompletion = NO;
		transform.autoreverses = NO;
		[self.lineLayer addAnimation:transform forKey:nil];
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

@interface GOLayer ()

@property (nonatomic, strong) CALayer *lineSubLayer;

@end

@implementation GOLayer

- (instancetype)copyWithZone:(NSZone *)zone {
    GOLayer *layer = [[GOLayer allocWithZone:zone] init];
    return layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super init]) {
        self.frame = frame;
        self.drawsAsynchronously = YES;// 进行异步绘制
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers]; /// 异步执行、处理子视图数据
    [self setNeedsDisplay];  /// 异步执行、自动调用drawInContext绘图方法
	
	self.lineSubLayer = [CALayer layer];
	self.lineSubLayer.frame = CGRectMake((self.bounds.size.width - 8) * 0.5, 0, 8, self.bounds.size.width * 0.5);
	//self.lineSubLayer.backgroundColor = [UIColor.redColor colorWithAlphaComponent:1].CGColor;
	self.lineSubLayer.contents = (id)[UIImage imageNamed:@"common_circle_arrow"].CGImage;
	self.lineSubLayer.contentsScale = [UIScreen mainScreen].scale;
	[self setMask:self.lineSubLayer];
}

//绘制尾巴
- (void)drawInContext:(CGContextRef)ctx {
//	CGContextSaveGState(ctx);
//	UIBezierPath *topArcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width * 0.5,  self.bounds.size.width * 0.5) radius:self.bounds.size.width * 0.5 - 10 startAngle:-M_PI_2 endAngle:-M_PI_2 - M_PI_2 * 0.15 clockwise:NO];
//	UIBezierPath *bottomArcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width * 0.5,  self.bounds.size.width * 0.5) radius:self.bounds.size.width * 0.5 - 30 startAngle:-M_PI_2 endAngle:-M_PI_2 - M_PI_2 * 0.15 clockwise:NO];
//	UIBezierPath *shadowPath = [UIBezierPath bezierPath];
//	[shadowPath appendPath:[topArcPath bezierPathByReversingPath]];
//	[shadowPath addLineToPoint:CGPointMake(self.bounds.size.width * 0.5, 20)];
//	[shadowPath appendPath:bottomArcPath];
//	[shadowPath addLineToPoint:[[self points:topArcPath].lastObject CGPointValue]];
//	//[shadowPath applyTransform:CGAffineTransformMakeTranslation(0, 10)];
//	[self drawLinearGradientWithPathContext:ctx path:shadowPath.CGPath startColor:[UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor endColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor];
//	CGContextRestoreGState(ctx);
}

- (void)drawLinearGradientWithPathContext:(CGContextRef)context
									 path:(CGPathRef)path
							   startColor:(CGColorRef)startColor
								 endColor:(CGColorRef)endColor {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = {0.0, 1.0};
	
	NSArray *colors = @[(__bridge id)startColor,(__bridge id)endColor];
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors,locations);
	CGRect pathRect = CGPathGetBoundingBox(path);
	
	//具体方向可根据需求修改
	CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMinY(pathRect));
	CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMinY(pathRect));
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 1);
	CGContextClip(context);
	
	CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextStrokePath(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

- (NSArray *)points:(UIBezierPath *)currPath
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(currPath.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}


void getPointsFromBezier(void *info,const CGPathElement *element){
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    if (type != kCGPathElementCloseSubpath) {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            [bezierPoints addObject:VALUE(1)];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        [bezierPoints addObject:VALUE(2)];
    }
    
}

@end


