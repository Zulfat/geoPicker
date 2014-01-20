//
//  ViewController.h
//  gUp
//
//  Created by Miftakhutdinov Zulfat on 27.12.13.
//  Copyright (c) 2013 Miftakhutdinov Zulfat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface ViewController : UIViewController <MKMapViewDelegate,UITableViewDataSource,NSURLConnectionDataDelegate,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property NSMutableArray* positions;// массив из дикшинари с адресами из гугл плэйс
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSURLConnection* connection;
@property CLLocationCoordinate2D selectedPosition; // выбранная позиция должна быть в необходимой форме
@property (weak, nonatomic) IBOutlet UIView *mapView;// контейнер куда карта добавляется как субвью
- (IBAction)Ready:(id)sender;
@property NSMutableData* jsonData;// получаемые адреса из google places (для асинхронной загрузки)
@end
