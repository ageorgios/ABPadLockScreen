// ABPadLockScreenAbstractViewController.m
//
// Copyright (c) 2014 Aron Bury - http://www.aronbury.com
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

#import "ABPadLockScreenAbstractViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"

#define lockScreenView ((ABPadLockScreenView *) [self view])

@interface ABPadLockScreenAbstractViewController ()

- (void)setUpButtonMapping;
- (void)buttonSelected:(UIButton *)sender;
- (void)cancelButtonSelected:(UIButton *)sender;
- (void)deleteButtonSeleted:(UIButton *)sender;

@end

@implementation ABPadLockScreenAbstractViewController

#pragma mark -
#pragma mark - init methods
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentPin = @"";
        _pinLength = 4; //default to 4
    }
    return self;
}

- (id)initWithPinLength:(NSUInteger)pinLength
{
    self = [super init];
    if (self)
    {
        if (pinLength > 0) {
            _pinLength = pinLength;
        }
        else {
            _pinLength = 4;
        }
        _currentPin = @"";
    }
    return self;
}


#pragma mark -
#pragma mark - View Controller Lifecycele Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[ABPadLockScreenView alloc] initWithFrame:self.view.frame pinLength: self.pinLength];
    [self setUpButtonMapping];
    [lockScreenView.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [lockScreenView.deleteButton addTarget:self action:@selector(deleteButtonSeleted:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIUserInterfaceIdiom interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (interfaceIdiom == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    if (interfaceIdiom == UIUserInterfaceIdiomPhone) return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark - Localisation Methods
- (void)setLockScreenTitle:(NSString *)title
{
    self.title = title;
    lockScreenView.enterPasscodeLabel.text = title;
}

- (void)setSubtitleText:(NSString *)text
{
    lockScreenView.detailLabel.text = text;
}

- (void)setCancelButtonText:(NSString *)text
{
    [lockScreenView.cancelButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.cancelButton sizeToFit];
}

- (void)setDeleteButtonText:(NSString *)text
{
    [lockScreenView.deleteButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.deleteButton sizeToFit];
}

#pragma mark -
#pragma mark - Helper Methods
- (void)setUpButtonMapping
{
    for (UIButton *button in [lockScreenView buttonArray])
    {
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)cancelButtonDisabled:(BOOL)disabled
{
    lockScreenView.cancelButtonDisabled = disabled;
}

- (void)processPin
{
    //Subclass to provide concrete implementation
}

#pragma mark -
#pragma mark - Button Methods
- (void)newPinSelected:(NSInteger)pinNumber
{
    if ([self.currentPin length] >= self.pinLength)
    {
        return;
    }
    
    self.currentPin = [NSString stringWithFormat:@"%@%ld", self.currentPin, (long)pinNumber];
    
    NSUInteger curSelected = [self.currentPin length] - 1;
    [lockScreenView.digitsArray[curSelected]  setSelected:YES animated:YES completion:nil];
    
    if ([self.currentPin length] == 1)
    {
        [lockScreenView showDeleteButtonAnimated:YES completion:nil];
    }
    else if ([self.currentPin length] == self.pinLength)
    {
        [lockScreenView.digitsArray.lastObject setSelected:YES animated:YES completion:nil];
        [self processPin];
    }
}

- (void)deleteFromPin
{
    if ([self.currentPin length] == 0)
    {
        return;
    }
    
    self.currentPin = [self.currentPin substringWithRange:NSMakeRange(0, [self.currentPin length] - 1)];
    
    NSUInteger pinToDeselect = [self.currentPin length];
    [lockScreenView.digitsArray[pinToDeselect] setSelected:NO animated:YES completion:nil];
    
    if ([self.currentPin length] == 0)
    {
        [lockScreenView showCancelButtonAnimated:YES completion:nil];
    }
}

- (void)buttonSelected:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    [self newPinSelected:tag];
}

- (void)cancelButtonSelected:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockWasCancelledForPadLockScreenViewController:)])
    {
        [self.delegate unlockWasCancelledForPadLockScreenViewController:self];
    }
}

- (void)deleteButtonSeleted:(UIButton *)sender
{
    [self deleteFromPin];
}

@end
