#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize robot;
@synthesize calibrateHandler;

#define refValue 0.65f
#define netrefValue -0.65f

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];
    [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
    
    obe = [[OBE alloc] initWithDelegate:self];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [RKRobotDiscoveryAgent startDiscovery];
}

- (void)appWillResignActive:(NSNotification *)notification {
    [RKRobotDiscoveryAgent stopDiscovery];
    [RKRobotDiscoveryAgent disconnectAll];
}

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification *)notification {

    switch (notification.type) {
        case RKRobotConnecting:
            break;
        case RKRobotOnline:
            robot = [[RKOllie alloc] initWithRobot:notification.robot];
            [calibrateHandler setRobot:robot.robot];
            [robot enableCollisions:true];
            [robot addResponseObserver:self];
            break;
        case RKRobotDisconnected:
            [calibrateHandler setRobot:nil];
            robot = nil;
            [RKRobotDiscoveryAgent startDiscovery];
            break;
        default:
            break;
    }
}

// Listens for the collisions, provided the class is registered for responses
-(void)handleAsyncMessage:(RKAsyncMessage *)message forRobot:(id<RKRobotBase>)robot {
    if ([message isKindOfClass:[RKCollisionDetectedAsyncData class]]) {
        // Collision detected!
        NSLog(@"Collision");
        
        if(obe != nil){
            obe.Motor1 = 1.0f; obe.Motor2 = 1.0f; obe.Motor3 = 1.0f; obe.Motor4 = 1.0f;
            [obe updateMotorState];
            
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(stopScanning:) userInfo:nil repeats:NO];
        }
    }
}

- (void) stopScanning:(id)sender{
    NSTimer *timer = (NSTimer *)sender;
    [timer invalidate];
    
    if(obe != nil){
        obe.Motor1 = 0.0f; obe.Motor2 = 0.0f; obe.Motor3 = 0.0f; obe.Motor4 = 0.0f;
        [obe updateMotorState];
    }
}

- (IBAction)stopPressed:(id)sender {
    [robot stop];
}

- (IBAction)zeroPressed:(id)sender {
        [self moveToHeading:0.0 velocity:0.6];
}

- (IBAction)ninetyPressed:(id)sender {
        [self moveToHeading:90.0 velocity:0.6];
}

- (IBAction)oneEightyPressed:(id)sender {
        [self moveToHeading:180.0 velocity:0.6];
}

- (IBAction)twoSeventyPressed:(id)sender {
        [self moveToHeading:270.0 velocity:0.6];
}

- (IBAction)sliderValueChanged:(id)sender {
    [robot driveWithHeading:round(self.slider.value) andVelocity:0.0];
    NSLog(@"Slider: %f", self.slider.value);
}

-(void)moveToHeading:(float)heading velocity:(float)velocity {
    [robot driveWithHeading:heading andVelocity:velocity];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(stop:) userInfo:nil repeats:NO];
}

-(void)stop:(NSTimer *)timer {
    [robot stop];
}

#pragma mark OBEDelegate

- (void) onOBEFound:(NSString *)name Index:(int)index{
    NSLog(@"OBE Found: %@", name);
    
    // connect upon discovering first OBE
    [obe connectToOBE:index];
}

- (void) onOBEConnected:(NSString *)name{
    NSLog(@"Connected to: %@", name);
}

- (void) onOBEDisconnected:(NSString *)name{
    NSLog(@"Disconnected from: %@", name);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                    message:@"Disconnected from OBE"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) onBatteryUpdated:(float)batteryLevel{
    NSLog(@"Battery %f", batteryLevel); // percentage
}

// Quaternion data updated
- (void) onQuaternionsUpdated:(OBEQuaternion *)left :(OBEQuaternion *)right :(OBEQuaternion *)center{
    
}

// There was a button pressed or unpressed. Check current button state manually.
- (void) onButtonsUpdated{
    //NSLog(@"Button %i", obe.LeftButton1);
    /*if(obe.LeftButton1){
        if(!l1){
            [self moveToHeading:0.0 velocity:0.3];
            l1 = true; isStopped = false;
        }
    }else if(obe.LeftButton2){
        if(!l2){
            [self moveToHeading:90.0 velocity:0.3];
            l2 = true; isStopped = false;
        }
    }else if(obe.LeftButton3){
        if(!l3){
            [self moveToHeading:180.0 velocity:0.3];
            l3 = true; isStopped = false;
        }
    }else if(obe.LeftButton4){
        if(!l4){
            [self moveToHeading:270.0 velocity:0.3];
            l4 = true; isStopped = false;
        }
    }else{
        if(!isStopped){
            [robot stop];
            isStopped = true;
        }
        
        l1 = false; l2 = false; l3 = false, l4 = false;
    }*/
    
    float pitch = obe.rightHand.pitch * 180 / 3.1416;
    float roll = obe.rightHand.roll * 180 / 3.1416;
    
    if(roll > 30){
        if(!l1){
            [self moveToHeading:0.0 velocity:0.65];
            l1 = true; isStopped = false;
            
            NSLog(@"Heading 0");
            
            //return;
        }
    }else if(roll < -30){
        if(!l2){
            [self moveToHeading:180.0 velocity:0.65];
            l2 = true; isStopped = false;
            
            NSLog(@"Heading 90");
            //return;
        }
    }
    
    else if(pitch > 35){
        if(!l3){
            [self moveToHeading:90.0 velocity:0.65];
            l3 = true; isStopped = false;
            
            NSLog(@"Heading 180");
            //return;
        }
    }else if(pitch < -35){
        if(!l4){
            [self moveToHeading:270.0 velocity:0.65];
            l4 = true; isStopped = false;
            
            NSLog(@"Heading 270");
            //return;
        }
    }
    
    /*else if((obe.rightHand.roll < refValue) && (obe.rightHand.roll > netrefValue) && (obe.rightHand.pitch < refValue) && (obe.rightHand.pitch > netrefValue)){
        if(!isStopped){
            [robot stop];
            isStopped = true;
            
            NSLog(@"Stopped");
        }
        
        l1 = false; l2 = false; l3 = false, l4 = false;
    }*/
    else{
        if(!isStopped){
            [robot stop];
            isStopped = true;
            
            NSLog(@"Stopped");
        }
        
        l1 = false; l2 = false; l3 = false, l4 = false;
    }
}

#pragma mark IBFunctions

- (IBAction)search:(id)sender{
    //obe = [[OBE alloc] init];
    //[obe setDelegate:self];
    
    [obe startScanning];
    
    NSLog(@"Scan started");
}

@end
