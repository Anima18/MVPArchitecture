//
//  DataBean.m
//  Pods
//
//  Created by jianjianhong on 17/8/7.
//
//

#import "DataBean.h"

@implementation DataBean

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return propertyGenericClass;
}

+ (void)setPropertyGenericClass:(NSDictionary *)classes {
    propertyGenericClass = classes;
}
@end
