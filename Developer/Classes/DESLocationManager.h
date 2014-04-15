//
//  DESLocationManager.h
//  Describe
//
//  Created by Describe Administrator on 15/04/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class DESLocationManager;

@protocol DESLocationManagerDelegate <NSObject>

@optional
- (void)didUpdatedToNewLocation:(DESLocationManager *)locationManager;

@end

@interface DESLocationManager : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, weak) id<DESLocationManagerDelegate> delegate;

+ (DESLocationManager *)sharedLocationManager;

- (void)initializeFetchingCurrentLocationAndStartUpdating:(BOOL)startLocation;

- (void)startFetchingCurrentLocation;

- (void)stopFetchingCurrentLocation;

@end
