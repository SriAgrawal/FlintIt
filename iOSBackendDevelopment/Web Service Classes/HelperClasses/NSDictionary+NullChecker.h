//
//  NSDictionary+NullChecker.h
//  PartyApp
//
//  Created by KrishnaKant kaira on 04/03/14.
//  Copyright (c) 2014 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullChecker)

-(id)objectForKeyNotNull:(id)object expectedObj:(id)obj;
-(id)objectForKeyNotNull:(id)key;

+(id)dictionaryWithContentsOfJSONURLData:(NSData *)JSONData;
-(NSData*)toJSON;

@end
