//
//  SWSAlertView.m
//  SWSAlertView
//
//  Created by 施文松 on 2018/3/1.
//  Copyright © 2018年 施文松. All rights reserved.
//


#define kWindow [UIApplication sharedApplication].keyWindow
// 宽高
#define _kWidth [[UIScreen mainScreen] bounds].size.width
#define _kHeight [[UIScreen mainScreen] bounds].size.height

/**
 获取颜色
 @param rgbValue 0x999999
 @return UIColor
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "SWSAlertView.h"
#import <SDAutoLayout/SDAutoLayout.h>
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

@interface SWSAlertView ()



@property (copy, nonatomic) id completeBlock;

@property (assign, nonatomic) BOOL isInput;

@end

@implementation SWSAlertView

+ (SWSAlertView *)shareInstance{
//	static SWSAlertView *shareInstance = nil;
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
		SWSAlertView *shareInstance = [[self alloc] init];
//	});
	return shareInstance;
}


- (void)sws_showInView:(UIView *)superView
			 withTitle:(NSString *)titleString
		   withMessage:(NSString *)message
 withCancelButtonTitle:(NSString *)canleButtonTitle
	 otherButtonTitles:(NSString *)otherButtonTitle
		  withComplete:(void(^)(NSInteger type))complete{
	self.completeBlock = complete;
	
	UIView *grayView = [[UIView alloc] init];
	grayView.alpha = 0.0;
	[self addSubview:grayView];
	grayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
	grayView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
	grayView.userInteractionEnabled = YES;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)];
	[grayView addGestureRecognizer:tap];
	self.grayView = grayView;
	
	if (superView) {
		[self removeFromSuperview];
		[superView addSubview:self];
		self.frame = superView.frame;
	}else{
		[kWindow addSubview:self];
		self.frame = kWindow.frame;
	}
	
	[self beginSet];
	
	CGFloat whiteViewWidth = _kWidth - 40;
	UIView *whiteView = [[UIView alloc] init];
	whiteView.alpha = 0.0;
	self.whiteView = whiteView;
	[self addSubview:whiteView];
	whiteView.backgroundColor = UIColorFromRGB(0xfffffff);
	whiteView.layer.cornerRadius = 6.0;
	whiteView.layer.masksToBounds = YES;
	whiteView.sd_layout
	.centerXEqualToView(self)
	.centerYEqualToView(self)
	.widthIs(whiteViewWidth);
	
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = titleString;
	titleLabel.font = [UIFont systemFontOfSize:16];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel = titleLabel;
	[whiteView addSubview:titleLabel];
	titleLabel.sd_layout
	.topSpaceToView(whiteView, 20)
	.leftSpaceToView(whiteView, 20)
	.rightSpaceToView(whiteView, 20)
	.autoHeightRatio(0);
	
	CGFloat textHeight = [SWSAlertView getStringHeightWithString:message withWidth:(whiteViewWidth - 40) withHeight:MAXFLOAT withFont:14];
	UILabel *messageLabel = [[UILabel alloc] init];
	messageLabel.userInteractionEnabled = NO;
	messageLabel.text = message;
	messageLabel.font = [UIFont systemFontOfSize:14];
	messageLabel.textAlignment = textHeight > 20 ?  NSTextAlignmentLeft : NSTextAlignmentCenter;
	self.messageLabel = messageLabel;
	[whiteView addSubview:messageLabel];
	messageLabel.sd_layout
	.topSpaceToView(titleLabel, titleString.length == 0 ? 0 : 20)
	.leftSpaceToView(whiteView, 20)
	.rightSpaceToView(whiteView, 20)
	.autoHeightRatio(0);
	messageLabel.textColor = UIColorFromRGB(0X959595);
	
	UIView *line = [[UIView alloc] init];
	line.backgroundColor = UIColorFromRGB(0XF7F7F7);
	[whiteView addSubview:line];
	line.sd_layout
	.leftSpaceToView(whiteView, 0)
	.rightSpaceToView(whiteView, 0)
	.topSpaceToView(messageLabel, message.length == 0 ? 0 : 20)
	.heightIs(1.0);


	
	if (canleButtonTitle.length > 0) {
		UIButton *canleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[canleButton setTitle:canleButtonTitle forState:UIControlStateNormal];
		[canleButton setTitleColor:UIColorFromRGB(0X252525) forState:UIControlStateNormal];
		[canleButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
		[whiteView addSubview:canleButton];
		self.canleButton = canleButton;
		canleButton.tag = 0;
		[canleButton addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	if (otherButtonTitle.length > 0) {
		UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
		[otherButton setTitleColor:UIColorFromRGB(0X00AB23) forState:UIControlStateNormal];
		[otherButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
		[whiteView addSubview:otherButton];
		self.otherButton = otherButton;
		otherButton.tag = 1;
		[otherButton addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	NSMutableArray *buttonsArray = [NSMutableArray array];
	if (self.canleButton) {
		[buttonsArray addObject:self.canleButton];
	}
	
	if (self.otherButton) {
		[buttonsArray addObject:self.otherButton];
	}
	
	if (buttonsArray.count > 0) {
		if (buttonsArray.count == 1) {
			UIButton *button = buttonsArray.firstObject;
			button.sd_layout
			.topSpaceToView(line, 0)
			.leftEqualToView(whiteView)
			.rightEqualToView(whiteView)
			.heightIs(54.0);
		}else if (buttonsArray.count == 2){
			UIButton *firstButton = buttonsArray.firstObject;
			firstButton.sd_layout
			.topSpaceToView(line, 0)
			.leftEqualToView(whiteView)
			.widthRatioToView(whiteView, 0.5)
			.heightIs(54.0);
			
			UIButton *lastButton = buttonsArray.lastObject;
			lastButton.sd_layout
			.topSpaceToView(line, 0)
			.leftSpaceToView(firstButton, 0)
			.rightEqualToView(whiteView)
			.heightIs(54.0);
			
			UIView *line1 = [[UIView alloc] init];
			line1.backgroundColor = UIColorFromRGB(0XF7F7F7);
			[whiteView addSubview:line1];
			line1.sd_layout
			.leftSpaceToView(firstButton, 0)
			.topEqualToView(firstButton)
			.bottomEqualToView(firstButton)
			.widthIs(1.0);
		}
		
		[whiteView setupAutoHeightWithBottomViewsArray:[NSArray arrayWithArray:buttonsArray] bottomMargin:0];
	}else{
		[whiteView setupAutoHeightWithBottomViewsArray:@[line] bottomMargin:0];
	}
	
	
	whiteView.transform = CGAffineTransformMakeScale(0.4, 0.4);
	/// show
	[UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		
		grayView.alpha = 1.0;
		
		whiteView.alpha = 1.0;
		whiteView.transform = CGAffineTransformMakeScale(1.0, 1.0);
	
	} completion:^(BOOL finished) {
		
	}];
}

//MARK: - 输入(弹出输入框)
- (void)sws_showInputInView:(UIView *)superView
				  withTitle:(NSString *)titleString
		   withKeyboardType:(UIKeyboardType)keyboardType
			withPlaceHolder:(NSString *)placeHolder
	  withCancelButtonTitle:(NSString *)canleButtonTitle
		  otherButtonTitles:(NSString *)otherButtonTitle
			   withComplete:(void(^)(NSInteger type, NSString *inputString))complete{

	self.isInput = YES;
	
	self.completeBlock = complete;
	
	if (superView) {
		[self removeFromSuperview];
		[superView addSubview:self];
		self.frame = superView.frame;
	}else{
		[kWindow addSubview:self];
		self.frame = kWindow.frame;
	}
	[self beginSet];

	
	UIView *grayView = [[UIView alloc] init];
	grayView.alpha = 0.0;
	[self addSubview:grayView];
	grayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
	grayView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
	grayView.userInteractionEnabled = YES;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)];
	[grayView addGestureRecognizer:tap];
	self.grayView = grayView;
	
	
	CGFloat whiteViewWidth = _kWidth - 60;
	UIView *whiteView = [[UIView alloc] init];
	whiteView.alpha = 0.0;
	self.whiteView = whiteView;
	[self addSubview:whiteView];
	whiteView.backgroundColor = UIColorFromRGB(0xfffffff);
	whiteView.layer.cornerRadius = 6.0;
	whiteView.layer.masksToBounds = YES;
	whiteView.sd_layout
	.centerXEqualToView(grayView)
	.centerYEqualToView(grayView)
	.widthIs(whiteViewWidth);
	
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = titleString;
	titleLabel.font = [UIFont systemFontOfSize:16];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel = titleLabel;
	[whiteView addSubview:titleLabel];
	titleLabel.sd_layout
	.topSpaceToView(whiteView, 20)
	.leftSpaceToView(whiteView, 20)
	.rightSpaceToView(whiteView, 20)
	.autoHeightRatio(0);
	
	UITextField *inputTextField = [[UITextField alloc] init];
	inputTextField.placeholder = placeHolder;
	inputTextField.font = [UIFont systemFontOfSize:14];
	self.inputTextField = inputTextField;
	[whiteView addSubview:inputTextField];
	inputTextField.sd_layout
	.topSpaceToView(titleLabel, titleString.length == 0 ? 0 : 20)
	.leftSpaceToView(whiteView, 20)
	.rightSpaceToView(whiteView, 20)
	.heightIs(38);
	inputTextField.borderStyle = UITextBorderStyleNone;
	inputTextField.layer.borderColor = UIColorFromRGB(0XF7F7F7).CGColor;
	inputTextField.layer.borderWidth = 0.5;
	inputTextField.keyboardType = keyboardType;
	inputTextField.textColor = UIColorFromRGB(0X959595);
	
	UIView *line = [[UIView alloc] init];
	line.backgroundColor = UIColorFromRGB(0XF7F7F7);
	[whiteView addSubview:line];
	line.sd_layout
	.leftSpaceToView(whiteView, 0)
	.rightSpaceToView(whiteView, 0)
	.topSpaceToView(inputTextField, 20)
	.heightIs(1.0);
	
	
	
	if (canleButtonTitle.length > 0) {
		UIButton *canleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[canleButton setTitle:canleButtonTitle forState:UIControlStateNormal];
		[canleButton setTitleColor:UIColorFromRGB(0X252525) forState:UIControlStateNormal];
		[canleButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
		[whiteView addSubview:canleButton];
		self.canleButton = canleButton;
		canleButton.tag = 0;
		[canleButton addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	if (otherButtonTitle.length > 0) {
		UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
		[otherButton setTitleColor:UIColorFromRGB(0X56BA6C) forState:UIControlStateNormal];
		[otherButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
		[whiteView addSubview:otherButton];
		self.otherButton = otherButton;
		otherButton.tag = 1;
		[otherButton addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	NSMutableArray *buttonsArray = [NSMutableArray array];
	if (self.canleButton) {
		[buttonsArray addObject:self.canleButton];
	}
	
	if (self.otherButton) {
		[buttonsArray addObject:self.otherButton];
	}
	
	if (buttonsArray.count > 0) {
		if (buttonsArray.count == 1) {
			UIButton *button = buttonsArray.firstObject;
			button.sd_layout
			.topSpaceToView(line, 0)
			.leftEqualToView(whiteView)
			.rightEqualToView(whiteView)
			.heightIs(54.0);
		}else if (buttonsArray.count == 2){
			UIButton *firstButton = buttonsArray.firstObject;
			firstButton.sd_layout
			.topSpaceToView(line, 0)
			.leftEqualToView(whiteView)
			.widthRatioToView(whiteView, 0.5)
			.heightIs(54.0);
			
			UIButton *lastButton = buttonsArray.lastObject;
			lastButton.sd_layout
			.topSpaceToView(line, 0)
			.leftSpaceToView(firstButton, 0)
			.rightEqualToView(whiteView)
			.heightIs(54.0);
			
			UIView *line1 = [[UIView alloc] init];
			line1.backgroundColor = UIColorFromRGB(0XF7F7F7);
			[whiteView addSubview:line1];
			line1.sd_layout
			.leftSpaceToView(firstButton, 0)
			.topEqualToView(firstButton)
			.bottomEqualToView(firstButton)
			.widthIs(1.0);
		}
		
		[whiteView setupAutoHeightWithBottomViewsArray:[NSArray arrayWithArray:buttonsArray] bottomMargin:0];
	}else{
		[whiteView setupAutoHeightWithBottomViewsArray:@[line] bottomMargin:0];
	}

	whiteView.transform = CGAffineTransformMakeScale(0.4, 0.4);
	/// show
	[UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		
		grayView.alpha = 1.0;
		
		whiteView.alpha = 1.0;
		whiteView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		
	} completion:^(BOOL finished) {
		
	}];
}


- (void)tapOnClick:(UITapGestureRecognizer *)tap{
	[self endEditing:YES];

//	if (self.isInput) {
//		[self endEditing:YES];
//		return;
//	}
//	[self dismiss];
}

- (void)buttonOnClick:(UIButton *)button{
	if (self.isInput) {
		void(^completeBlock)(NSInteger type, NSString *inputString) = self.completeBlock;
		if (completeBlock) {
			completeBlock(button.tag, self.inputTextField.text);
		}
	}else{
		void(^completeBlock)(NSInteger type) = self.completeBlock;
		if (completeBlock) {
			completeBlock(button.tag);
		}
	}
	[self dismiss];

}

- (void)dismiss{
	[self endSet];
	
	self.whiteView.sd_layout.widthIs(0);
	
	[UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		
		self.grayView.alpha = 0.0;
		self.whiteView.alpha = 0.0;
		self.whiteView.transform = CGAffineTransformMakeScale(0.4, 0.4);
		
	} completion:^(BOOL finished) {
		[self.grayView removeFromSuperview];
		[self removeFromSuperview];
	}];
	
}

- (void)beginSet{
	[self endEditing:YES];

	UINavigationController *navigationController = (UINavigationController *)self.findViewContrller;
	navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
}

- (void)endSet{
	UINavigationController *navigationController = (UINavigationController *)self.findViewContrller;
	navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}

/*FIXME: - 计算文字的高度*/
+ (float)getStringHeightWithString:(NSString*)string withWidth:(float)width withHeight:(float)height withFont:(float)font1
{
	
	UIFont *font = [UIFont systemFontOfSize:font1];
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
	NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
	CGRect frame = [string boundingRectWithSize:CGSizeMake(width,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
	return ceilf(frame.size.height);
}

@end


@implementation UIView (AlertExtension)

/**
 *  这个是我们封装好的获取响应者链的一个方法
 *
 *  @return 返回我们根据响应者链找到的ViewController
 */
- (UIViewController *)findViewContrller
{
	UIResponder *nextObj = self.nextResponder;
	while (nextObj != nil) {
		nextObj = nextObj.nextResponder;
		if ([nextObj isKindOfClass:[UIViewController class]]) {
			return (UIViewController *)nextObj;
		}
	}
	return nil;
}
@end
