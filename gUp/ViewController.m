//
//  ViewController.m
//  gUp
//
//  Created by Miftakhutdinov Zulfat on 27.12.13.
//  Copyright (c) 2013 Miftakhutdinov Zulfat. All rights reserved.
//

#import "ViewController.h"
#import "geoUpdater.h"
#import "JSONKit.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize table;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selected = NO;
    self.loaded = NO;
    self.results = NO;
    self.isSatelite = NO;
    self.map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - self.tapBar.frame.size.height-66)];// инициализируем карту
    [self.view addSubview:self.map];//
    [self.map setShowsUserLocation:YES];// показывать позицию пользователя
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];// следить за положением пользователя
    [self.map setCenterCoordinate:self.map.userLocation.coordinate];
    [self.map setDelegate:self];
    self.positions = [[NSMutableArray alloc] init];
    [self.tapBar setSelectedItem:[[self.tapBar items] objectAtIndex:2]];
    self.changeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 90, 30, 30)];
    [self.changeViewButton addTarget:self action:@selector(changeMapView) forControlEvents:UIControlEventTouchUpInside];
    [self.changeViewButton setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.changeViewButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.positions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PositionCell"];
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    if (!cell)
        cell = [UITableViewCell alloc];
    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PositionCell"];
    [[cell textLabel] setText:[[self.positions objectAtIndex:indexPath.row] valueForKey:@"name"]];
    if (!self.results && !self.selected) {
        CLLocationCoordinate2D coordinates;
        coordinates.latitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lat" ] doubleValue];
        coordinates.longitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lng"] doubleValue];
        [annotation setCoordinate:coordinates];
        [annotation setTitle:@"PlacesAnn"];
        [self.map addAnnotation:annotation];
    }
    else
        if (!self.loaded && !self.selected){
            dispatch_queue_t annque = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(annque, ^{
                [self addAllAnnotations];
            });
            self.loaded=true;
        }
    return cell;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!self.jsonData)
        self.jsonData = [[NSMutableData alloc] init];
    [self.jsonData appendData:data];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLocationCoordinate2D coordinates;
    coordinates.latitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lat" ] doubleValue];
    coordinates.longitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lng"] doubleValue];
    self.selectedPosition = coordinates;
    [self.map setUserTrackingMode:MKUserTrackingModeNone];
    [self.map setCenterCoordinate:coordinates animated:YES];
    [self.map removeAnnotations:[self.map annotations]];
    MKPointAnnotation *chosedAnn = [[MKPointAnnotation alloc] init];
    [chosedAnn setTitle:@"PlacesAnn"];
    [chosedAnn setCoordinate:coordinates];
    [self.map addAnnotation:chosedAnn];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary* resDict = [self.jsonData objectFromJSONData];
    self.positions = [resDict valueForKey:@"results"];
    self.results = YES;
    [self.table reloadData];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    MKPinAnnotationView* pinAnnView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotattion"];
    if ([[annotation title] isEqualToString:@"PlacesAnn"])
        [pinAnnView setPinColor:MKPinAnnotationColorGreen];
    else
    if ([[annotation title] isEqualToString:@"Выбранная позиция"])
        [pinAnnView setPinColor:MKPinAnnotationColorRed];
    else
        [pinAnnView setPinColor:MKPinAnnotationColorPurple];
    return pinAnnView;
}
- (IBAction)Ready:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.map];
    CLLocationCoordinate2D coordinates = [self.map convertPoint:location toCoordinateFromView:self.map];
    self.selectedPosition = coordinates;
    [self.map removeAnnotations:[self.map annotations]];
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinates];
    [annotation setTitle:@"Выбранная позиция"];
    [self.map addAnnotation:annotation];
}
-(void) showTable{
    [self addAllAnnotations];
    [self.map setFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 66 - self.table.frame.size.height - self.tapBar.frame.size.height)];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.spaceTapBar.constant =0;                     }];
}
-(void) hideTable {
    [self.map setFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - self.tapBar.frame.size.height-66)];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.spaceTapBar.constant = - self.table.frame.size.height-66;
                     }];
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([[item title] isEqualToString:@"Места"]) {
        [self.map removeGestureRecognizer:self.tapgr];
        self.tapgr = nil;
        [self.map setShowsUserLocation:NO];
        [self showTable];
    }
    if ([[item title] isEqualToString:@"Текущее положение"]) {
        self.selected = NO;
        [self.map removeGestureRecognizer:self.tapgr];
        self.tapgr = nil;
        [self.map setShowsUserLocation:YES];
        [self hideTable];
        [self.map removeAnnotations:[self.map annotations]];
        [self.map setCenterCoordinate:self.map.userLocation.coordinate];
    }
    if ([[item title] isEqualToString:@"Выбрать на карте"]) {
        self.selected = NO;
        self.tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForTapRecognizer:)];
        [self.map addGestureRecognizer:self.tapgr];
        [self.map setShowsUserLocation:NO];
        [self hideTable];
        [self.map removeAnnotations:[self.map annotations]];
        MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.map.userLocation.coordinate];
        [annotation setTitle:@"Выбранная позиция"];
        [self.map addAnnotation:annotation];
        [self.map setCenterCoordinate:self.map.userLocation.coordinate];
        
    }
}
-(void) addAllAnnotations{
    [self.map removeAnnotations:[self.map annotations]];
    MKPointAnnotation* ann;
    CLLocationCoordinate2D coordinates;
    for (NSDictionary* pos in self.positions) {
        coordinates = CLLocationCoordinate2DMake([[[[pos valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lat" ] doubleValue], [[[[pos valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lng" ] doubleValue]);
        ann = [[MKPointAnnotation alloc] init];
        [ann setCoordinate:coordinates];
        [ann setTitle:@"PlacesAnn"];
        [self.map addAnnotation:ann];
    }
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
    if (!self.results) {
        NSString* urlstr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&sensor=false&key=AIzaSyA-Zxt-TkvFHvX5xLthh53bJ-NaIe4fzpw",self.map.userLocation.coordinate.latitude,self.map.userLocation.coordinate.longitude];
        [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstr]];
        if (!self.connection)
            self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    }
}
-(void) changeMapView {
    if (!self.isSatelite)
        [self.map setMapType:MKMapTypeSatellite];
    else
        [self.map setMapType:MKMapTypeStandard];
    self.isSatelite = !self.isSatelite;
}
@end
