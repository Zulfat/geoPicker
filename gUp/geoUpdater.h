//
//  geoUpdater.h
//  gUp
//
//  Created by Miftakhutdinov Zulfat on 27.12.13.
//  Copyright (c) 2013 Miftakhutdinov Zulfat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface geoUpdater : NSObject <CLLocationManagerDelegate>
@property CLLocation* position;
@property CLLocationManager* Manager;
@property int timeInterval;
@property NSTimer* timer;
+(geoUpdater*) sharedGeoUpdater;//+
-(void) setTimeInterval:(int)minutes;//+
-(void) Update;//+
-(void) prepareInstance;//+
-(NSDictionary*) getInfo:(CLLocation*) location;
-(NSDictionary*) Position;
- (NSMutableDictionary *)forwardGeocodeWithLanguage:(CLLocation*) position;
@end
