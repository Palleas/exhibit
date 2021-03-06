//
// Created by Simon de Carufel on 15-06-02.
// Copyright (c) 2015 Simon de Carufel. All rights reserved.
//

#import "PresentationView.h"
#import "UIView+MCLayout.h"
#import "SlideView.h"
#import "Moment.h"
#import "AvatarView.h"
#import "AUBAvatar.h"
#import <Aubergiste/AUBOrganization.h>

@interface PresentationView ()
@property (nonatomic) CGSize referenceSize;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) UIImageView *firstBackgroundImageView;
@property (nonatomic) UIImageView *secondBackgroundImageView;
@property (nonatomic) UIImageView *nwadLogoImageView;
@property (nonatomic) UILabel *lifeAtLabel;
@property (nonatomic) SlideView *currentSlideView;
@property (nonatomic) BOOL moveLeft;
@property (nonatomic) NSTimeInterval duration;
@end

@implementation PresentationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityIndicatorView setHidesWhenStopped:YES];
        [self.activityIndicatorView startAnimating];
        [self addSubview:self.activityIndicatorView];

        self.firstBackgroundImageView = [UIImageView new];
        self.firstBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.firstBackgroundImageView.alpha = 0;
        [self addSubview:self.firstBackgroundImageView];

        self.secondBackgroundImageView = [UIImageView new];
        self.secondBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.secondBackgroundImageView.alpha = 0;
        [self addSubview:self.secondBackgroundImageView];

        self.nwadLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NWADLogoPicto"]];
        self.nwadLogoImageView.alpha = 0;
        [self addSubview:self.nwadLogoImageView];

        self.lifeAtLabel = [UILabel new];
        self.lifeAtLabel.textColor = [UIColor whiteColor];
        self.lifeAtLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
        self.lifeAtLabel.shadowOffset = CGSizeMake(0, 1);
        self.lifeAtLabel.alpha = 0;
        [self addSubview:self.lifeAtLabel];

        self.moveLeft = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.mc_size, self.referenceSize)) {

        CGFloat logoWidth = roundf(self.mc_width * 0.03f);

        self.referenceSize = self.mc_size;
        CGSize backgroundSize = CGRectInset(self.bounds, -0.02f * self.mc_width, 0).size;
        [self.activityIndicatorView mc_setPosition:MCViewPositionCenters];
        [self.firstBackgroundImageView mc_setPosition:MCViewPositionCenters withMargins:UIEdgeInsetsZero size:backgroundSize];
        [self.secondBackgroundImageView mc_setPosition:MCViewPositionCenters withMargins:UIEdgeInsetsZero size:backgroundSize];
        [self.nwadLogoImageView mc_setPosition:MCViewPositionBottomLeft withMargins:UIEdgeInsetsMake(0, 10, 10, 0) size:CGSizeMake(logoWidth, logoWidth)];
        [self.currentSlideView mc_setPosition:MCViewPositionCenters withMargins:UIEdgeInsetsZero size:self.mc_size];
    }
    [self.lifeAtLabel mc_setRelativePosition:MCViewRelativePositionToTheRightCentered toView:self.nwadLogoImageView withMargins:UIEdgeInsetsMake(0, 20, 0, 0) size:[self.lifeAtLabel sizeThatFits:CGSizeZero]];
}

//------------------------------------------------------------------------------
#pragma mark - Public Methods
//------------------------------------------------------------------------------

- (void)setOrganization:(AUBOrganization *)organization
{
    CGFloat textSize = roundf(self.nwadLogoImageView.mc_width * 0.45f);
    self.lifeAtLabel.font = [UIFont fontWithName:@"Lato-Medium" size:textSize];
    self.lifeAtLabel.text = [NSString stringWithFormat:NSLocalizedString(@"life_at_organization", nil), organization.name];
    [self setNeedsLayout];
}

- (void)transitionToMoment:(Moment *)moment duration:(NSTimeInterval)duration
{
    self.duration = duration;
    self.moveLeft = !self.moveLeft;

    if (self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView stopAnimating];
    }

    if (self.currentSlideView) {
        [self.currentSlideView dismissMoment:^{
            [self.currentSlideView removeFromSuperview];
            self.currentSlideView = nil;
            [self transitionBackground:moment.blurredBackground duration:duration];
        }];
    } else {
        [self transitionBackground:moment.blurredBackground duration:duration];
    }

    [self performSelector:@selector(presentMoment:) withObject:moment afterDelay:1.0f];

    if (self.nwadLogoImageView.alpha < 1) {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.nwadLogoImageView.alpha = 1;
            self.lifeAtLabel.alpha = 1;
        } completion:nil];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private Methods
//------------------------------------------------------------------------------

- (void)transitionBackground:(UIImage *)backgroundImage duration:(NSTimeInterval)duration
{
    UIImageView *appearingImageView = self.moveLeft ? self.firstBackgroundImageView : self.secondBackgroundImageView;
    UIImageView *disappearingImageView = self.moveLeft ? self.secondBackgroundImageView : self.firstBackgroundImageView;

    appearingImageView.image = backgroundImage;
    appearingImageView.transform = CGAffineTransformIdentity;

    [UIView animateWithDuration:1.0f animations:^{
        appearingImageView.alpha = 0.8f;
        disappearingImageView.alpha = 0;
    } completion:^(BOOL finished) {
        disappearingImageView.image = nil;
    }];
}

- (void)presentMoment:(Moment *)moment
{
    if (self.currentSlideView) return;
    
    self.currentSlideView = [[SlideView alloc] initWithMoment:moment moveLeft:self.moveLeft];
    [self addSubview:self.currentSlideView];
    [self.currentSlideView mc_setPosition:MCViewPositionCenters withMargins:UIEdgeInsetsZero size:self.mc_size];

    [self.currentSlideView presentMoment:^{
        if ([self.delegate respondsToSelector:@selector(didCompleteTransition)]) {
            [self.delegate didCompleteTransition];
        }
    }];

    CGFloat translationX = 0.02f * self.mc_width * (self.moveLeft ? -1 : 1);

    UIImageView *currentBackgroundImageView = self.moveLeft ? self.firstBackgroundImageView : self.secondBackgroundImageView;

    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.currentSlideView.transform = CGAffineTransformMakeTranslation(translationX, 0);
        currentBackgroundImageView.transform = CGAffineTransformMakeTranslation(-translationX, 0);
    } completion:^(BOOL finished) {
    }];
}
@end