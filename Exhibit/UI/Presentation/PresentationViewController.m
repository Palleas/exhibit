//
// Created by Simon de Carufel on 15-06-02.
// Copyright (c) 2015 Simon de Carufel. All rights reserved.
//

#import "PresentationViewController.h"
#import "SlideshowController.h"
#import "PresentationView.h"
#import "Moment.h"
#import "Settings.h"

@interface PresentationViewController() <PresentationViewDelegate, SlideshowObserver>
@property (nonatomic) SlideshowController *slideshowController;
@property (nonatomic) Settings *settings;
@property (nonatomic) PresentationView *presentationView;
@end

@implementation PresentationViewController
- (instancetype)initWithSlideshowController:(SlideshowController *)slideshowController settings:(Settings *)settings
{
    if (self = [super init]) {
        _slideshowController = slideshowController;
        _settings = settings;
    }
    return self;
}

- (void)loadView
{
    self.presentationView = [PresentationView new];
    self.presentationView.delegate = self;
    self.view = self.presentationView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.presentationView setOrganization:self.settings.organization];
    [self.slideshowController addSlideshowObserver:self];
    [self.slideshowController startSlideshow];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.slideshowController removeSlideshowObserver:self];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

//------------------------------------------------------------------------------
#pragma mark - SlideshowObserver
//------------------------------------------------------------------------------


- (void)didLoadMoments:(NSInteger)numberOfMoments
{

}

- (void)displayMoment:(Moment *)moment atChronologicalIndex:(NSInteger)index
{
    [self.presentationView transitionToMoment:moment duration:self.slideshowController.slideDuration];
}

//------------------------------------------------------------------------------
#pragma mark - PresentationViewDelegate
//------------------------------------------------------------------------------

- (void)didCompleteTransition
{
}
@end