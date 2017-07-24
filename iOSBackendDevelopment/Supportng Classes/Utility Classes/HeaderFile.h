//
//  HeaderFiles.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 01/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#ifndef HeaderFiles_h
#define HeaderFiles_h

/*
 * Import all header files + framework + categories + custom components etc
 */

/* =============== Importing Frameworks===================== */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <Messages/Messages.h>
#import <MessageUI/MessageUI.h>


#import "AppDelegate.h"
//***************** Category Classes *********************************//
#import "UIViewController+CWPopup.h"
#import "UIImage+CC.h"

//************* Utility Classes **********************************//
#import "DTConstants.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "OPServiceHelper.h"
#import "BDVCountryNameAndCode.h"

#import "NSDictionary+NullChecker.h"
#import "EDKeyboardAvoidingCollectionView.h"
#import "EDKeyboardAvoidingScrollView.h"
#import "EDKeyboardAvoidingTableView.h"
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
#import "AppDateFormatter.h"
#import "MZSelectableLabel.h"
#import "UIColor+Equalable.h"
#import "DXStarRatingView.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AlertView.h"
#import "ADCircularMenu.h"
#import "UserInfo.h"
#import "RowDataModal.h"
#import "MacroFile.h"
#import "AppUtilityFile.h"
#import "OptionsPickerSheetView.h"
#import "SZTextView.h"
#import "SocialHelper.h"
#import "CountryNamesAndPhoneNumberPrefix.h"
#import "SignUpPopUpViewController.h"
#import "NSString+Validate.h"
#import "TableViewWithMultipleSelection.h"
#import "CDLanguageHandler.h"
#import "MJPopupBackgroundView.h"
#import "UIViewController+MJPopupViewController.h"
#import "SubscriptionPlanPopUpVC.h"
#import "UserInfo.h"


/*************************** View Controllers *************************/

#import "SelectLanguageVC.h"
#import "SignUpVC.h"
#import "LoginVC.h"
#import "MobileRegistrationVC.h"
#import "ReportProfileVC.h"
#import "EmailListViewController.h"
#import "EditProfileVC.h"
#import "NotificationViewController.h"
#import "AcceptedJobVC.h"
#import "JobCancelledVC.h"
#import "JobCompletedVC.h"
#import "ChangePasswordVC.h"
#import "MessagesVC.h"
#import "EmailVC.h"
#import "ForgotPasswordVC.h"
#import "TermsVC.h"
#import "FavouritesVC.h"
#import "MenuVC.h"
#import "FilterVC.h"
#import "ServiceTrackingVC.h"
#import "SelectChoiceVC.h"
#import "ProfileDetailVC.h"
#import "CategoryNameVC.h"
#import "SignUpViewController.h"
#import "SelectChoiceViewController.h"
#import "EditProfileViewController.h"
#import "GiveReviewVC.h"
#import "MenuSectionViewController.h"
#import "EmailViewVC.h"
#import "ProviderDetial.h"
#import "ChatVC.h"
#import "ReviewViewController.h"
#import "PopUPVC.h"
#import "MapScreenVC.h"
#import "ProviderLocationViewController.h"
#import "JobRequestVC.h"
#import "GiveAReviewServiceSideVC.h"
#import "ProfileViewController.h"
#import "ClientDetailViewController.h"
#import "StatusAvailableBusyVC.h"
#import "ServiceTrackingViewController.h"
#import "AudioPlayerVC.h"

/*************************** Modal class *************************/
#import "UserInfo.h"
#import "RowDataModal.h"
#import "EmailDataModal.h"
#import "NotificationRelatedData.h"
#import "ReviewRelatedData.h"
#import "CCPagination.h"
#import "ChatInfo.h"
#import "CategoryModal.h"

/************** Custom UITableViewCells ************************/
#import "SignUpTableViewCell.h"
#import "GenderTableViewCell.h"
#import "LoginCell.h"
#import "NotificationTableViewCell.h"
#import "MessagesTableViewCell.h"
#import "FavouritesTableViewCell.h"
#import "MenuTableViewCell.h"
#import "ServiceTrackingTableViewCell.h"
#import "SelectChoiceCollectionViewCell.h"
#import "CategoryNameTableViewCell.h"
#import "ProfileDetailCell.h"
#import "DescriptionTableViewCell.h"
#import "CustomTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "ServiceProviderEmailRow.h"
#import "ClientMailRow.h"
#import "RecieverMessageCell.h"
#import "SenderMessageCell.h"
#import "ReviewTableViewCell.h"
#import "JobRequestCell.h"
#import "ProfileTableViewCell.h"
#import "ScrollTableViewCell.h"
#import "ClientDetailTableViewCell.h"
#import "RatingTableViewCell.h"
#import "UserTableViewCell.h"
#import "ServiceTableViewCell.h"
#import "SubscriptionPopUpTableCell.h"

/*********************Custom UICollectionViewCells*************/
#import "SignUpCollectionViewCell.h"
#import "ProfileCollectionCell.h"

#endif /* HeaderFiles_h */
