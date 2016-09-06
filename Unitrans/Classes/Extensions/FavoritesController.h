//
//  FavoritesController.h
//  DavisTrans
//
//  Created by Kip on 4/11/10.
//  Copyright 2010 Kip Nicol & Ken Zheng
//

#import <Foundation/Foundation.h>

@class Route;
@class Stop;

@interface FavoritesController : NSObject {
    NSMutableArray *favorites;
}

@property (nonatomic, retain) NSArray *favorites;

+ (FavoritesController *)sharedFavorites;

- (void)addFavoriteStop:(Stop *)stop forRoute:(Route *)route;
- (void)removeFavoriteStop:(Stop *)stop forRoute:(Route *)route;

- (BOOL)isFavoriteStop:(Stop *)stop forRoute:(Route *)route;
- (NSArray *)allFavoriteStopsForRoute:(Route *)route;
- (NSString *)pathForFavoritesData;

- (void)saveFavoritesData;
- (void)loadFavoritesDataWithRoutes:(NSArray *)routes;

- (Route *)routeObjectForShortName:(NSString *)shortName fromRoutes:(NSArray *)routes;
- (Stop *)stopObjectForRoute:(Route *)route withStopCode:(NSNumber *)stopCode;

@end
