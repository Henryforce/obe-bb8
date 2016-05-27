#import <UIKit/UIKit.h>
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>
#import "OBESDK_iOS/OBE.h"

@interface ViewController : UIViewController<OBEDelegate>{
    OBE *obe;
    
    BOOL l1, l2, l3, l4, isStopped;
}

    @property (strong, nonatomic) RKConvenienceRobot *robot;
    @property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;
    @property (strong, nonatomic) IBOutlet UISlider *slider;

    - (IBAction)stopPressed:(id)sender;
    - (IBAction)zeroPressed:(id)sender;
    - (IBAction)ninetyPressed:(id)sender;
    - (IBAction)oneEightyPressed:(id)sender;
    - (IBAction)twoSeventyPressed:(id)sender;
    - (IBAction)sliderValueChanged:(id)sender;

- (IBAction)search:(id)sender;

@end