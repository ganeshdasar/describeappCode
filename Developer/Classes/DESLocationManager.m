//
//  DESLocationManager.m
//  Describe
//
//  Created by Describe Administrator on 15/04/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESLocationManager.h"

@interface DESLocationManager () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@end

@implementation DESLocationManager

+ (DESLocationManager *)sharedLocationManager
{
    static DESLocationManager *sharedInstance = nil;
    static dispatch_once_t locationOnceToken;
    dispatch_once(&locationOnceToken, ^{
        sharedInstance = [[DESLocationManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark Methods handling fetching of current location

- (void)initializeFetchingCurrentLocationAndStartUpdating:(BOOL)startLocation
{
    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = 10.0;
        locationManager.activityType = CLActivityTypeOtherNavigation;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
    }
    
    if(startLocation) {
        [self startFetchingCurrentLocation];
    }
}

- (void)startFetchingCurrentLocation
{
    if(locationManager != nil) {
        [locationManager startUpdatingLocation];
    }
    else {
        [self initializeFetchingCurrentLocationAndStartUpdating:YES];
    }
}

- (void)stopFetchingCurrentLocation
{
    if(locationManager != nil) {
        [locationManager stopUpdatingLocation];
        _currentLocation = nil;
        locationManager = nil;
    }
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(locations != nil && locations.count) {
        _currentLocation = locations[0];
        if(nil != _delegate && [_delegate respondsToSelector:@selector(didUpdatedToNewLocation:)]) {
            [_delegate didUpdatedToNewLocation:self];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _currentLocation = nil;
    if(nil != _delegate && [_delegate respondsToSelector:@selector(didUpdatedToNewLocation:)]) {
        [_delegate didUpdatedToNewLocation:self];
    }
}

@end
