//
//  geoUpdater.m
//  gUp
//
//  Created by Miftakhutdinov Zulfat on 27.12.13.
//  Copyright (c) 2013 Miftakhutdinov Zulfat. All rights reserved.
//

#import "geoUpdater.h"
#import "JSONKit.h"
@implementation geoUpdater
@synthesize Manager;
@synthesize timer;
+(geoUpdater *)sharedGeoUpdater {
    
    static geoUpdater  * instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[geoUpdater alloc] init];
            [instance prepareInstance];
        }
    }
    
    return instance;
}
-(void) prepareInstance {
    Manager = [[CLLocationManager alloc] init];
    Manager.delegate=self;
    _position = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Position"]];
    double lon = _position.coordinate.longitude;
    [Manager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0){
    _position = [locations objectAtIndex:[locations count]-1];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_position] forKey:@"Position"];
    [Manager stopUpdatingLocation];
}
-(void) setTimeInterval:(int)minutes {
    _timeInterval = minutes;
    if (timer)
        [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:minutes*60 target:self selector:@selector(Update) userInfo:Nil repeats:YES];
}
-(void) Update {
    [Manager startUpdatingLocation];
}
-(NSDictionary*) Position {
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval*60 target:self selector:@selector(Update) userInfo:Nil repeats:YES];
    [Manager startUpdatingLocation];
    return [self getInfo:_position];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    _position = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Position"]];
}
-(NSDictionary*) getInfo:(CLLocation*) location {
    NSMutableDictionary* infoDic = [self forwardGeocodeWithLanguage:_position];
    NSNumber* lat = [NSNumber numberWithDouble:(double)_position.coordinate.latitude];
    [infoDic setObject:lat forKey:@"lat"];
    lat = [NSNumber numberWithDouble:(double)_position.coordinate.longitude];
    [infoDic setObject:lat forKey:@"lng"];
    [infoDic setObject:[NSNumber numberWithBool:YES] forKey:@"sensor"];
    return infoDic;
}
- (NSMutableDictionary *)forwardGeocodeWithLanguage:(CLLocation*) position//преобразование position в адрес через google maps API
{
    NSString *gUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",(double)position.coordinate.latitude, (double)position.coordinate.longitude];
    
    gUrl = [gUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *infoData = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:gUrl]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    
    NSString *value = @"";
    NSURL* url = [[NSURL alloc] initWithString:gUrl];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    NSData* somedata = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    NSDictionary* dic = [somedata objectFromJSONData];
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    NSDictionary* infodictionary = [infoData objectFromJSONString];
    if ((infoData == nil) || (![[[infoData objectFromJSONString] objectForKey:@"status"] isEqual:@"OK"] ))
    {
        NSMutableDictionary *viewport;
        NSMutableDictionary *southwest;
        NSMutableDictionary *northeast;
        [northeast setObject:[NSNumber numberWithDouble:(double)_position.coordinate.latitude] forKey:@"lat"];
        [northeast setObject:[NSNumber numberWithDouble:(double)_position.coordinate.longitude] forKey:@"lng"];
        [southwest setObject:[NSNumber numberWithDouble:(double)_position.coordinate.latitude] forKey:@"lat"];
        [southwest setObject:[NSNumber numberWithDouble:(double)_position.coordinate.longitude] forKey:@"lng"];
        [viewport setObject:southwest forKey:@"southwest"];
        [viewport setObject:northeast forKey:@"northeast"];
        [result setObject:viewport forKey:@"viewport"];
        [result setObject:@"ROOFTOP" forKey:@"type"];
        [result setObject:@"" forKey:@"addres"];
    }
    else
    {
        NSDictionary *jsonObject = [infoData objectFromJSONString];
        
        NSDictionary *dict = [(NSDictionary *)jsonObject objectForKey:@"results"];
        for (id key in dict)
        {
                value = [NSString stringWithFormat:@"%@", [key objectForKey:@"formatted_address"]];
                [result setObject:[[key objectForKey:@"geometry"] objectForKey:@"viewport"] forKey:@"viewport"];
                [result setObject:value forKey:@"addres"];
                [result setObject:[[key objectForKey:@"geometry"] objectForKey:@"location_type" ] forKey:@"type"];
              break;
        }
    }
    return result;
}

@end
