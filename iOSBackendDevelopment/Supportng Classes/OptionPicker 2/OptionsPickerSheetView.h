//
//  OptionsPickerSheetView.m
//  VPW
//
//  Created by Vasu Saini on 27/07/16.
//  Copyright © 2016 Mobiloitte Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroFile.h"


typedef void(^OptionPickerSheetBlock)(NSString  *selectedText,NSInteger selectedIndex);
typedef void(^OptionPickerSheetBlockForCountryPicker)(NSMutableDictionary  *selectedDict,NSInteger selectedIndex);

@interface OptionsPickerSheetView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

+ (id)sharedPicker;

-(void)showPickerSheetWithOptions:(NSArray *)options AndComplitionblock:(OptionPickerSheetBlock )block;
//+(void)removePickerView;
-(void)showPickerSheetWithCountryFlags:(OptionPickerSheetBlockForCountryPicker)block;
@end
