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
#import "annotationClass.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize table;
- (void)viewDidLoad
{
    self.map = [[MKMapView alloc] initWithFrame:self.mapView.frame];// инициализируем карту
    [self.mapView addSubview:self.map];
    [self.map setShowsUserLocation:YES];
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.map setCenterCoordinate:self.map.userLocation.coordinate];
    [self.map setDelegate:self];
    self.positions = [[NSMutableArray alloc] init];
    [self.view addSubview:self.table];
    UITapGestureRecognizer* tagr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForTapRecognizer:)];
    [self.map addGestureRecognizer:tagr];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    geoUpdater* upd = [geoUpdater sharedGeoUpdater];
    NSString* urlstr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&sensor=false&key=AIzaSyA-Zxt-TkvFHvX5xLthh53bJ-NaIe4fzpw",upd.position.coordinate.latitude,upd.position.coordinate.longitude];
    [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstr]];
    if (!self.connection)
        self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    return [self.positions count]+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PositionCell"];
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PositionCell"];
    if (indexPath.row==[self.positions count]) {
        [[cell textLabel] setTintColor:[UIColor blueColor]];
        [[cell textLabel] setText:@"Текущее позиция"];
         annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coordinates=self.map.userLocation.coordinate;
        [annotation setCoordinate:coordinates];
        [annotation setTitle:@"Текущая позиция"];
        [self.map addAnnotation:annotation];
        return cell;
    }
    if (indexPath.row==[self.positions count]+1) {
        [[cell textLabel] setTintColor:[UIColor blueColor]];
        [[cell textLabel] setText:@"Выбрать на карте"];
        return cell;
    }
    [[cell textLabel] setText:[[self.positions objectAtIndex:indexPath.row] valueForKey:@"name"]];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lat" ] doubleValue];
    coordinates.longitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lng"] doubleValue];
    [annotation setCoordinate:coordinates];
    [annotation setTitle:[[self.positions objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [self.map addAnnotation:annotation];
    return cell;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!self.jsonData)
        self.jsonData = [[NSMutableData alloc] init];
    [self.jsonData appendData:data];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLocationCoordinate2D coordinates;
    if (indexPath.row>=[self.positions count]) {
        coordinates = self.map.userLocation.coordinate;
        if (indexPath.row==[self.positions count]+1) {
            CGPoint offpoint = CGPointMake(10, 10);
            [self.table setContentOffset:offpoint animated:YES];
        }
    }
    else {
        coordinates.latitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lat" ] doubleValue];
        coordinates.longitude=[[[[[self.positions objectAtIndex:indexPath.row] valueForKey:@"geometry"] valueForKey:@"location" ] valueForKey:@"lng"] doubleValue];
        self.selectedPosition = coordinates;
    }
    [self.map setUserTrackingMode:MKUserTrackingModeNone];
    [self.map setCenterCoordinate:coordinates animated:YES];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary* resDict = [self.jsonData objectFromJSONData];
    self.positions = [resDict valueForKey:@"results"];
    [self.table reloadData];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
}
- (IBAction)Ready:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    // Get the location of the gesture
    CGPoint location = [recognizer locationInView:self.view];
    CLLocationCoordinate2D coordinates = [self.map convertPoint:location toCoordinateFromView:self.map];
    self.selectedPosition = coordinates;
    [self.map setCenterCoordinate:coordinates];
}
@end
