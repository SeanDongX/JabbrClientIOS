//
//  CLAUserRegistrationViewModel.h
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAUserRegistrationViewModel : NSObject

@property  (nonatomic, strong) NSString *username;
@property  (nonatomic, strong) NSString *email;
@property  (nonatomic, strong) NSString *password;
@property  (nonatomic, strong) NSString *confirmPassword;
@end
