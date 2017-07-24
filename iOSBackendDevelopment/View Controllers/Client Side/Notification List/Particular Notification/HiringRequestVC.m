//
//  HiringRequestVC.m
//  iOSBackendDevelopment
//
//  Created by Lalit Kumar on 26/11/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HiringRequestVC.h"
#import "MacroFile.h"

@interface HiringRequestVC ()

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *userAgeLbl;
@property (strong, nonatomic) IBOutlet UILabel *userLocationLbl;
@property (strong, nonatomic) IBOutlet UILabel *userPaymentLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UIButton *userPhoneBtn;
@property (strong, nonatomic) IBOutlet UIButton *viewProfileBtn;

- (IBAction)backBtnAction:(UIButton *)sender;
- (IBAction)viewProfileBtnAction:(UIButton *)sender;

@end

@implementation HiringRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDefault];

}
-(void)setUpDefault{
    CLLocationDegrees latitude = [[APPDELEGATE latitude] doubleValue];
    CLLocationDegrees longitude = [[APPDELEGATE longitude] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reverse Gecoding to get address from (lat,long)

-(void)getUserUpdateLocation : (CLLocationCoordinate2D) coordinate {
    // Your location from latitude and longitude
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    //  __block NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
    __block NSString *str = nil;
    // Call the method to find the address
    [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
        if ([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length] && [[d valueForKey:@"Street"] length]) {
            str = [NSString stringWithFormat:@"%@, %@, %@ , %@",[d valueForKey:@"City"],[d valueForKey:@"State"],[d valueForKey:@"Country"],[d valueForKey:@"Street"]];
        }
        else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"State"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"City"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"City"]];
        }else if([[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"Country"]];
        }else{
            str = @"";
        }
        self.userLocationLbl.text = str;
        //  cell.tagLbl.text = str;
        
    } failureHandler:^(NSError *error) {
        NSLog(@"Error : %@", error);
    }
     ];
    //    return finalDic;
    
}
- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler{
    // NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler([NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary]);
            }
        }
    }];
}

- (IBAction)backBtnAction:(UIButton *)sender {
}

- (IBAction)viewProfileBtnAction:(UIButton *)sender {
}
@end
