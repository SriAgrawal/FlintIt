//
//  TableViewWithMultipleSelection.m
//  TableViewLikePicker
//
//  Created by Abhishek Agarwal on 11/06/16.
//  Copyright © 2016 Abhishek Agarwal. All rights reserved.


#import "TableViewWithMultipleSelection.h"
#import "AppDelegate.h"
#import "AppUtilityFile.h"
#import "HeaderFile.h"
#import "MacroFile.h"

static TableViewWithMultipleSelection *tableViewMultipleSelection = nil;
static NSString *cellIdentifier = @"Cell";

@interface TableViewWithMultipleSelection () <UITableViewDelegate,UITableViewDataSource> {
    
    UITableView *addedTableView;
    SelectedOptionInformation optionInformation;
    PickerDataModalSelection pickerDataModalSelection;

    NSArray *optionsArray;
    NSMutableArray *selectedObjectInformationArray;
}

@end

@implementation TableViewWithMultipleSelection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
    

        return self;
}

+ (id)sharedTableViewWithMultipleSelection {
    
    if (!tableViewMultipleSelection)
        tableViewMultipleSelection = [[TableViewWithMultipleSelection alloc] init];
    
    return tableViewMultipleSelection;
}

#pragma mark - UITableView Datasource and Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [optionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (([optionsArray[indexPath.row] isKindOfClass:[CategoryModal class]])) {
        CategoryModal *category = optionsArray[indexPath.row];

        cell.textLabel.text = category.categoryName;
        cell.accessoryType = (category.selectionStatus)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;

    } else {
        cell.textLabel.text = [optionsArray objectAtIndex:indexPath.row];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        SelectedOptionInformationModalClass *multipleOptions = [selectedObjectInformationArray objectAtIndex:indexPath.row];
        cell.accessoryType = (multipleOptions.selectedIndex == -1)?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([optionsArray[indexPath.row] isKindOfClass:[CategoryModal class]]) {
     
        // Assumes first object in array has always has the functionality of selection "All"
        
//        if (!indexPath.row) {
//            
//            CategoryModal *category = optionsArray[indexPath.row];
//            category.selectionStatus = !category.selectionStatus;
//
//            for (CategoryModal *otherCategory in optionsArray) {
//                otherCategory.selectionStatus = category.selectionStatus;
//            }
//            
//        } else {
            CategoryModal *category = optionsArray[indexPath.row];
            category.selectionStatus = !category.selectionStatus;
            
//            BOOL isAllSelected = YES;
//            
//            int index = 0;
//            
//            for (CategoryModal *otherCategory in optionsArray) {
//                
//                if (index) {
//                    if (!otherCategory.selectionStatus) {
//                        isAllSelected = NO;
//                        break;
//                    }
//                }
//                index++;
//            }
//            
//            CategoryModal *allCategory = optionsArray[0];
//            allCategory.selectionStatus = isAllSelected;

//        }
        [addedTableView reloadData];

        return;
    }
    
    SelectedOptionInformationModalClass *multipleOptions = [selectedObjectInformationArray objectAtIndex:indexPath.row];
    
    if (multipleOptions.selectedIndex == -1) {
        multipleOptions.selectedIndex = indexPath.row;
    }else {
        multipleOptions.selectedIndex = -1;
    }
    
//    // if all is selected.
//    if (indexPath.row == 0 && multipleOptions.selectedIndex == indexPath.row) {
//        NSLog(@"remove rest of data from list.");
//        for (SelectedOptionInformationModalClass *modalObject in selectedObjectInformationArray) {
//            if (!(modalObject.selectedIndex == 0)) {
//                
//                modalObject.selectedIndex = [selectedObjectInformationArray indexOfObject:modalObject];
//            }
//        }
//
//    }else if(indexPath.row == 0 && !(multipleOptions.selectedIndex == indexPath.row)){
//        for (SelectedOptionInformationModalClass *modalObject in selectedObjectInformationArray) {
//                modalObject.selectedIndex = -1;
//        }
//    }
//    else if(!(indexPath.row == 0) && multipleOptions.selectedIndex == -1)
//    {
//    // if other item is unselected.
//        NSLog(@"remove selection of all and particular index");
//        for (SelectedOptionInformationModalClass *modalObject in selectedObjectInformationArray) {
//            if (modalObject.selectedIndex == 0 ) {
//                modalObject.selectedIndex = -1;
//            }
//
//        }
//    }
    
    [addedTableView reloadData];
}

#pragma mark - TableView added with multiple options

-(void)addTableViewWithData:(NSArray *)options andCompletionBlock:(PickerDataModalSelection)block {
    pickerDataModalSelection = [block copy];

    // allocate new objects of modal so that the instance reference can remove
    
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (CategoryModal *modal in options) {
        CategoryModal *newReference = [[CategoryModal alloc] init];
        newReference.categoryName = modal.categoryName;
        newReference.selectionStatus = modal.selectionStatus;

        [tempArray addObject:newReference];
    }
    
    optionsArray = [tempArray mutableCopy];
    
    [self addTableView];
    [self addCancelAndDoneButton];
    [self addBlurViewBackground];
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    
    [UIView animateWithDuration:0.1 animations:^{
        tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height -260, appDel.window.frame.size.width, 260);
        [[appDel.window viewWithTag:786] setAlpha:0.50];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)addTableViewWithOptions:(NSMutableArray *)options andSelectedDataInfo:(NSMutableArray *)selectedDataArray andCompletionBlock:(SelectedOptionInformation)block {
    
    optionInformation = [block copy];
    
    optionsArray = [[NSArray alloc] initWithArray:options];
    selectedObjectInformationArray = [[NSMutableArray alloc]init];
    
    for (NSString *str in options) {
        SelectedOptionInformationModalClass *multipleOptions = [[SelectedOptionInformationModalClass alloc]init];
        multipleOptions.selectedObject = str;
        multipleOptions.selectedIndex = -1;
        
        [selectedObjectInformationArray addObject:multipleOptions];
    }

    
    for (NSString *str in selectedDataArray) {
        NSInteger indexNumber = [options indexOfObject:str];
         SelectedOptionInformationModalClass *multipleOptions = [selectedObjectInformationArray objectAtIndex:indexNumber];
         multipleOptions.selectedIndex = indexNumber;
        
        [selectedObjectInformationArray replaceObjectAtIndex:indexNumber withObject:multipleOptions];
    }
    
    [self addTableView];
    [self addCancelAndDoneButton];
    [self addBlurViewBackground];
    
    AppDelegate *appDel =(AppDelegate *) [[UIApplication sharedApplication] delegate];
//    tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
        tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
    
    
    [UIView animateWithDuration:0.1 animations:^{
        tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height -260, appDel.window.frame.size.width, 260);
        [[appDel.window viewWithTag:786] setAlpha:0.50];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)addTableView {
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    addedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40,  appDel.window.frame.size.width, 216)];
    [addedTableView setBackgroundColor:[UIColor clearColor]];
    addedTableView.showsVerticalScrollIndicator = YES;
    addedTableView.delegate = self;
    addedTableView.dataSource = self;
    addedTableView.separatorInset = UIEdgeInsetsZero;
    [tableViewMultipleSelection addSubview:addedTableView];
    
    [addedTableView reloadData];
}

-(void)addBlurViewBackground {
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    UIView *tempView = [[UIView alloc] initWithFrame:appDel.window.bounds];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [tempView setAlpha:0.0];
    [tempView setTag:786];
    
    [appDel.window addSubview:tempView];
    [appDel.window addSubview:tableViewMultipleSelection];
    [appDel.window bringSubviewToFront:tableViewMultipleSelection];
}

-(void)addCancelAndDoneButton {
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(5, 0, appDel.window.frame.size.width-10, 40)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneActionSheet:)];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelActionSheet:)];
    
    UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems: [NSArray arrayWithObjects:cancelBtn,flexibleSpace,doneBtn, nil] animated:NO];
    
    [tableViewMultipleSelection addSubview:toolBar];
}

#pragma mark - Done and Cancel Action

-(void)cancelActionSheet:(id)sender {
    [self removeTableView];
}

-(void)doneActionSheet:(id)sender {
    
    if ([[optionsArray firstObject] isKindOfClass:[CategoryModal class]]) {
        
        if (pickerDataModalSelection) {
            pickerDataModalSelection(optionsArray);
        }
        [self removeTableView];

        return;
    }
    
    
    NSMutableArray *selectedText = [NSMutableArray array];
    NSMutableArray *selectedIndex = [NSMutableArray array];

    for (SelectedOptionInformationModalClass *modalObject in selectedObjectInformationArray) {
     

        if (modalObject.selectedIndex != -1) {
            [selectedIndex addObject:[NSNumber numberWithInteger:modalObject.selectedIndex]];
            [selectedText addObject:modalObject.selectedObject];
        }
    }
    optionInformation(selectedText, selectedIndex);
    
    [self removeTableView];
}

-(void)removeTableView
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [UIView animateWithDuration:0.1 animations:^{
        tableViewMultipleSelection.frame = CGRectMake(0, appDel.window.frame.size.height, appDel.window.frame.size.width, 260);
        [[appDel.window viewWithTag:786] removeFromSuperview];

    } completion:^(BOOL finished) {

        for (id obj  in tableViewMultipleSelection.subviews) {
            [obj removeFromSuperview];
        }
        [tableViewMultipleSelection removeFromSuperview];
        tableViewMultipleSelection = nil;
    }];
}

@end

@implementation SelectedOptionInformationModalClass

@end
