
#import "RNLocationChange.h"
#import <CoreLocation/CLError.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@implementation RNLocationChange
{
    CLLocationManager * locationManager;
    NSDictionary<NSString *, id> * lastLocationEvent;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
    return @[@"significantLocationChange"];
}

RCT_EXPORT_METHOD(start) {
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 50;// meters
    locationManager.delegate = self;
    
    [locationManager startMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(stop) {
    if (nil == locationManager)
        return;
    
    [locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    
    lastLocationEvent = @{
                          @"coords": @{
                                  @"latitude": @(location.coordinate.latitude),
                                  @"longitude": @(location.coordinate.longitude),
                                  @"altitude": @(location.altitude),
                                  @"accuracy": @(location.horizontalAccuracy),
                                  @"altitudeAccuracy": @(location.verticalAccuracy),
                                  @"heading": @(location.course),
                                  @"speed": @(location.speed),
                                  },
                          @"timestamp": @([location.timestamp timeIntervalSince1970] * 1000) // in ms
                          };
    
    [self sendEventWithName:@"significantLocationChange" body:lastLocationEvent];
}

@end
