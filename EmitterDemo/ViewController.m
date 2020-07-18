//
//  ViewController.m
//  EmitterDemo
//
//  Created by caohouhong on 17/6/14.
//  Copyright © 2017年 caohouhong. All rights reserved.
//

#import "ViewController.h"
#import "GOEmitterCircleProgress.h"
#import "GONormalProgressView.h"

#define SCREEN_WIDTH     [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

// UIColor
#define ASColor(r, g, b, a)                     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ASColorHexAlpha(hexNumber, a)           [UIColor colorWithRed:(((float)((hexNumber & 0xFF0000) >> 16)) / 255.0) \
                                                green:(((float)((hexNumber & 0xFF00) >> 8)) / 255.0) \
                                                blue:(((float)(hexNumber & 0xFF)) / 255.0) alpha:a]
#define ASColorHex(hexNumber)                   ASColorHexAlpha(hexNumber, 1.0)
#define ASColorRandom                           ASColor(arc4random_uniform(256),\
                                                        arc4random_uniform(256),\
                                                        arc4random_uniform(256), 1.0)

@interface ViewController ()

@property (nonatomic, strong) GOEmitterCircleProgress *progressView;

@property (nonatomic, strong) GONormalProgressView *normalProgressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = UIColor.whiteColor;

    [self initEmitterLayer];
    [self initView];
	
	GOProgressConfig *config = GOProgressConfig.alloc.init;
	[config setRotate:NO];
	config.progressLineWidth = 6;
	
	config.backgroundProgressLineWitdh = 6;
	config.backgroundProgressLineColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
	
	config.progressCircleRadius = 40;
	config.gradientLayerColors = @[[ASColorHex(0xFFAE22) colorWithAlphaComponent:0.0], ASColorHex(0xFFAE22)];
	self.normalProgressView = [GONormalProgressView.alloc initWithFrame:CGRectMake(300, 500, 80, 80) config:config];
	config.innerColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x003DFF),
						  (id)ASColorHex(0xADDF00),
						  (id)ASColorHex(0xFFB600),
						  (id)ASColorHex(0xFF8700),
						  (id)ASColorHex(0xCF1C00),
						  (id)ASColorHex(0xCF1C00),nil];
	
	
	config.emitterColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x1978FF),
						  (id)ASColorHex(0xFBFF01),
						  (id)ASColorHex(0xFFDB00),
						  (id)ASColorHex(0xFF9700),
						  (id)ASColorHex(0xFF5500),
						  (id)ASColorHex(0xFF5500),nil];
	
	config.outerColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x0067FF),
						  (id)ASColorHex(0xD4FF00),
						  (id)ASColorHex(0xFFB600),
						  (id)ASColorHex(0xFF7700),
						  (id)ASColorHex(0xFF1600),
						  (id)ASColorHex(0xFF1600),nil];
	
	config.progressColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x00D3FF),
						  (id)ASColorHex(0xF8FF01),
						  (id)ASColorHex(0xFFDB00),
						  (id)ASColorHex(0xFFA300),
						  (id)ASColorHex(0xFF5D00),
						  (id)ASColorHex(0xFF5D00),nil];
	
	config.needleColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x39F8FF),
						  (id)ASColorHex(0xE6FF6C),
						  (id)ASColorHex(0xFFF364),
						  (id)ASColorHex(0xFFD564),
						  (id)ASColorHex(0xFFAD00),
						  (id)ASColorHex(0xFFAD00),nil];
	[self.view addSubview:self.normalProgressView];
	
	CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotateAnimation.fromValue = @(0);
	rotateAnimation.toValue = @(M_PI * 2);
	rotateAnimation.duration = 8;
	rotateAnimation.fillMode = kCAFillModeForwards;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	rotateAnimation.removedOnCompletion = NO; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
	rotateAnimation.repeatCount = MAXFLOAT;
	rotateAnimation.autoreverses = NO;
	[self.normalProgressView.rotateLayer addAnimation:rotateAnimation forKey:@"rotation"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initView{
    UIButton *clickButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 64, 100, 40)];
    clickButton.backgroundColor = [UIColor blueColor];
	[clickButton setTitle:@"暂停" forState:UIControlStateNormal];
	[clickButton setTitle:@"开始" forState:UIControlStateSelected];
	[clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[clickButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clickButton];
    self.view.backgroundColor = UIColor.blackColor;
	
    __weak typeof(self) ws = self;
    __block CGFloat index = 0;
	
	__block NSInteger time = 99990;
	[self.progressView.numberView updateNumbers:0 animation:AnimationTypeAutomatic duration:0.5];
	self.progressView.numberView.numberType = NumberTypeHour;
	self.progressView.numberView.numberSpace = 10;
	self.progressView.numberView.spaceValue = @":";
//
	__block NSArray *currArray = [NSArray arrayWithObjects:@(0.1),@(0.2),@(0.3),@(0.4),@(0.5), nil];
	__block NSInteger locationCount = currArray.count;
	__block CGFloat realTimeProgress = 0.01;
	[NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        index += (1/30.0);
        if (index >= 1) {
            index = 1;
            [timer invalidate];
            timer = nil;
        }
	
		time++;
        [self.progressView.numberView updateNumbers:time animation:AnimationTypeAutomatic duration:0.5];
		[ws.progressView setProgress:index animated:YES duration:1];
		[ws.normalProgressView setProgress:index animated:YES duration:1];
    }];
}

//粒子发射器
- (void)initEmitterLayer {
    
	GOProgressConfig *config = GOProgressConfig.alloc.init;
	config.progressLineWidth = 12;
	[config setShowNeedle:YES]; 
	
	config.backgroundProgressLineWitdh = 12;
	config.backgroundProgressLineColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
	config.progressCircleRadius = (SCREEN_WIDTH - 50) * 0.5 - 10;
	config.needleCircleRadius = (SCREEN_WIDTH - 50) * 0.5;
	config.innerShadowRadius = 60;
	config.outerShadowRadius = 6;
	config.gradientLayerColors = @[[ASColorHex(0xFFAE22) colorWithAlphaComponent:0.0], ASColorHex(0xFFAE22)];
	[config setUpdateColor:YES];
	config.innerColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x003DFF),
						  (id)ASColorHex(0xADDF00),
						  (id)ASColorHex(0xFFB600),
						  (id)ASColorHex(0xFF8700),
						  (id)ASColorHex(0xCF1C00),
						  (id)ASColorHex(0xCF1C00),nil];
	
	
	config.emitterColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x1978FF),
						  (id)ASColorHex(0xFBFF01),
						  (id)ASColorHex(0xFFDB00),
						  (id)ASColorHex(0xFF9700),
						  (id)ASColorHex(0xFF5500),
						  (id)ASColorHex(0xFF5500),nil];
	
	config.outerColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x0067FF),
						  (id)ASColorHex(0xD4FF00),
						  (id)ASColorHex(0xFFB600),
						  (id)ASColorHex(0xFF7700),
						  (id)ASColorHex(0xFF1600),
						  (id)ASColorHex(0xFF1600),nil];
	
	config.progressColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x00D3FF),
						  (id)ASColorHex(0xF8FF01),
						  (id)ASColorHex(0xFFDB00),
						  (id)ASColorHex(0xFFA300),
						  (id)ASColorHex(0xFF5D00),
						  (id)ASColorHex(0xFF5D00),nil];
	
	config.needleColors = [NSArray arrayWithObjects:
						  (id)ASColorHex(0x39F8FF),
						  (id)ASColorHex(0xE6FF6C),
						  (id)ASColorHex(0xFFF364),
						  (id)ASColorHex(0xFFD564),
						  (id)ASColorHex(0xFFAD00),
						  (id)ASColorHex(0xFFAD00),nil];
	
	config.locations = [NSArray arrayWithObjects:@(0.1),@(0.2),@(0.3),@(0.4),@(0.5), nil];

    self.progressView = [[GOEmitterCircleProgress alloc] initWithFrame:CGRectMake(25, 100, SCREEN_WIDTH - 50, SCREEN_WIDTH - 50) config:config];
	if (config.isShowNeedle == YES) {
	}
	else {
		CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
		rotateAnimation.fromValue = @(0 - M_PI_4);
		rotateAnimation.toValue = @(M_PI * 2 - M_PI_4);
		rotateAnimation.duration = 8;
		rotateAnimation.fillMode = kCAFillModeForwards;
		rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		rotateAnimation.removedOnCompletion = NO; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
		rotateAnimation.repeatCount = MAXFLOAT;
		rotateAnimation.autoreverses = NO;
		[self.progressView.lineLayer addAnimation:rotateAnimation forKey:@"rotation"];
	}
	
    [self.view addSubview:self.progressView];
	
}

// 下雪
- (void)buttonAction:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (!btn.selected){
        [self startAnimation];
    }else {
        [self stopAnimation];
    }
    
}

- (void) startAnimation{
    self.progressView.emitterLayer.birthRate = 1;
}

- (void) stopAnimation{
    self.progressView.emitterLayer.birthRate = 0;
}

@end
