//
//  OptionsPickerSheetView.m
//  VPW
//
//  Created by Vasu Saini on 27/07/16.
//  Copyright © 2016 Mobiloitte Technologies. All rights reserved.
//

#import "OptionsPickerSheetView.h"
#import "AppDelegate.h"
#import "BDVCountryNameAndCode.h"

OptionPickerSheetBlock optionPickerBlock;
OptionPickerSheetBlockForCountryPicker optionPickerBlockCountryPicker;

UIPickerView *pickerFiltering;
NSInteger     currentPick;
NSArray      *pickerOptions;
BOOL isCountryPicker;
NSArray *BDVCountryNameAndCodePlist;

static OptionsPickerSheetView *optionsPickerSheetView = nil;

@implementation OptionsPickerSheetView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        NSString* path = [[NSBundle mainBundle] pathForResource:@"BDVCountryNameAndCode" ofType:@"plist"];
        
        BDVCountryNameAndCodePlist = [NSArray arrayWithContentsOfFile:path];
    }
    return self;
}


+ (id)sharedPicker {
    
    if (!optionsPickerSheetView) {
        
        optionsPickerSheetView = [[OptionsPickerSheetView alloc] init];
    }
    
    return optionsPickerSheetView;
}


-(void)showPickerSheetWithOptions:(NSArray *)options AndComplitionblock:(OptionPickerSheetBlock)block
{
    [self endEditing:YES];
    optionPickerBlock = [block copy];
    
    pickerOptions = [[NSArray alloc] initWithArray:options];
    isCountryPicker = NO;
    currentPick = 0;
    
        pickerFiltering = [[UIPickerView alloc] init];
        pickerFiltering.showsSelectionIndicator =  YES;
        pickerFiltering.delegate = self;
        pickerFiltering.dataSource = self;
        
        
        [optionsPickerSheetView addSubview:pickerFiltering];
        
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];

      [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];

        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(5, 0, appDel.window.frame.size.width-10, 40)];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneActionSheet:)];
        doneBtn.tintColor = [UIColor blackColor];

        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
        cancelBtn.tintColor = [UIColor blackColor];

        UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems: [NSArray arrayWithObjects:cancelBtn,flexibleSpace,doneBtn, nil] animated:NO];
        [optionsPickerSheetView addSubview:toolBar];
        
    [pickerFiltering selectRow:currentPick inComponent:0 animated:NO];
    
    [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];
    
    [pickerFiltering setBackgroundColor:[UIColor clearColor]];
    [pickerFiltering reloadAllComponents];
    
    
    UIView *tempView = [[UIView alloc] initWithFrame:appDel.window.bounds];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [tempView setAlpha:0.0];
    [tempView setTag:786];
    
    
    [appDel.window addSubview:tempView];
    
    [appDel.window addSubview:optionsPickerSheetView];
    [appDel.window bringSubviewToFront:optionsPickerSheetView];
    
    optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height -260, appDel.window.frame.size.width, 260);
        [tempView setAlpha:0.50];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

-(void)showPickerSheetWithCountryFlags:(OptionPickerSheetBlockForCountryPicker)block
{
    [self endEditing:YES];
    optionPickerBlockCountryPicker = [block copy];
    isCountryPicker = YES;
    //pickerOptions = [[NSArray alloc] initWithArray:options];
    
    currentPick = 0;
    
    pickerFiltering = [[UIPickerView alloc] init];
    pickerFiltering.showsSelectionIndicator =  YES;
    pickerFiltering.delegate = self;
    pickerFiltering.dataSource = self;
    
    
    [optionsPickerSheetView addSubview:pickerFiltering];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(5, 0, appDel.window.frame.size.width-10, 40)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneActionSheet:)];
    doneBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
    cancelBtn.tintColor = [UIColor blackColor];

    UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems: [NSArray arrayWithObjects:cancelBtn,flexibleSpace,doneBtn, nil] animated:NO];
    [optionsPickerSheetView addSubview:toolBar];
    
    [pickerFiltering selectRow:currentPick inComponent:0 animated:NO];
    
    [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];
    
    [pickerFiltering setBackgroundColor:[UIColor clearColor]];
    [pickerFiltering reloadAllComponents];
    
    
    UIView *tempView = [[UIView alloc] initWithFrame:appDel.window.bounds];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [tempView setAlpha:0.0];
    [tempView setTag:786];
    
    
    [appDel.window addSubview:tempView];
    
    [appDel.window addSubview:optionsPickerSheetView];
    [appDel.window bringSubviewToFront:optionsPickerSheetView];
    
    optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height -260, appDel.window.frame.size.width, 260);
        [tempView setAlpha:0.50];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}


-(void)cancelActionSheet:(id)sender{
    [self removePickerView];
}
#pragma mark - Action Sheet Callback function
-(void)doneActionSheet:(id)sender{
    if(isCountryPicker)
        optionPickerBlockCountryPicker([BDVCountryNameAndCodePlist objectAtIndex:currentPick],currentPick);
    else
        optionPickerBlock([pickerOptions objectAtIndex:currentPick],currentPick);
    [self removePickerView];
}
-(void)removePickerView
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
        
    } completion:^(BOOL finished) {
        for (id obj  in optionsPickerSheetView.subviews) {
            [obj removeFromSuperview];
        }
        [optionsPickerSheetView removeFromSuperview];
        optionsPickerSheetView =nil;
        [[appDel.window viewWithTag:786] removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDelegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
      if(isCountryPicker)
    return  [BDVCountryNameAndCodePlist count];
    else
        return [pickerOptions count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    currentPick = row;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(isCountryPicker){
        if (!view)
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(27, 3, 200, 24)];
            UILabel *labelCountryCode = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 3, 200, 24)];
            
            label.backgroundColor = [UIColor clearColor];
            label.tag = 1;
            label.adjustsFontSizeToFitWidth = YES;
            //        if (self.labelFont) {
            //            label.font = self.labelFont;
            //        }
            [view addSubview:label];
           
            NSMutableDictionary *dict = [BDVCountryNameAndCodePlist objectAtIndex:row];
            label.text = [dict objectForKey:@"name"];
            
            labelCountryCode.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"dial_code"]];
            UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 24, 24)];
            flagView.contentMode = UIViewContentModeScaleAspectFit;
            flagView.tag = 2;
            flagView.image = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[dict objectForKey:@"code"]]];
            [view addSubview:labelCountryCode];
            [view addSubview:flagView];
        }
        return view;
    }
    UILabel *label = (UILabel *)view;
    
    if (!label)
    {
        // Customize your label (or any other type UIView) here
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, pickerView.bounds.size.width * 0.8, 25.0f)];
        
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    
    [label setBackgroundColor:[UIColor clearColor]];
//    if(windowWidth == 320)
//        [label setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
//    else if (windowWidth == 375)
//        [label setFont:[UIFont fontWithName:@"Helvetica" size:17.0f]];
//    else
        [label setFont:[UIFont fontWithName:@"Helvetica" size:19.0f]];
    if (row < [pickerOptions count])
    {
        label.text = (NSString *)[pickerOptions objectAtIndex:row];
        
    }
    return label;
}

-(void)showPickerSheetWithMonth:(NSArray *)options AndComplitionblock:(OptionPickerSheetBlock)block
{
    [self endEditing:YES];
    optionPickerBlock = [block copy];
    
    pickerOptions = [[NSArray alloc] initWithArray:options];
    isCountryPicker = NO;
    currentPick = 0;
    
  pickerFiltering = [[UIPickerView alloc] init];
    pickerFiltering.showsSelectionIndicator =  YES;
    pickerFiltering.delegate = self;
    pickerFiltering.dataSource = self;
    
    
    [optionsPickerSheetView addSubview:pickerFiltering];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(5, 0, appDel.window.frame.size.width-10, 40)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneActionSheet:)];
    doneBtn.tintColor = [UIColor blackColor];

    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
    cancelBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems: [NSArray arrayWithObjects:cancelBtn,flexibleSpace,doneBtn, nil] animated:NO];
    [optionsPickerSheetView addSubview:toolBar];
    
    [pickerFiltering selectRow:currentPick inComponent:0 animated:NO];
    
    [pickerFiltering setFrame:CGRectMake(0, 40, appDel.window.frame.size.width, 216)];
    
    [pickerFiltering setBackgroundColor:[UIColor clearColor]];
    [pickerFiltering reloadAllComponents];
    
    
    UIView *tempView = [[UIView alloc] initWithFrame:appDel.window.bounds];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [tempView setAlpha:0.0];
    [tempView setTag:786];
    
    
    [appDel.window addSubview:tempView];
    
    [appDel.window addSubview:optionsPickerSheetView];
    [appDel.window bringSubviewToFront:optionsPickerSheetView];
    
    optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    [UIView animateWithDuration:0.1 animations:^{
        optionsPickerSheetView.frame = CGRectMake(0, appDel.window.frame.size.height -260, appDel.window.frame.size.width, 260);
        [tempView setAlpha:0.50];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}


@end
