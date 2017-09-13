//
//  DataBean.h
//  Pods
//
//  Created by jianjianhong on 17/8/7.
//
//

#import <Foundation/Foundation.h>

static NSDictionary *propertyGenericClass;

@interface DataBean : NSObject

/* total */
@property NSInteger total;

/* rows */
@property NSArray *rows;

+ (void)setPropertyGenericClass:(NSDictionary *)classes;

@end
