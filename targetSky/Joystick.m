//
// Joystick.m
// http://idev.ofcode.com
//
// Created by neofar on 20/11/10.
//

#include <mach/mach.h>
#include <mach/mach_time.h>

#import "Joystick.h"
#import "CCDirector.h"

@implementation JoystickArea

@synthesize type; 
@synthesize joyId; 
@synthesize touchAddress;
@synthesize active;
@synthesize bounds;
@synthesize center;
@synthesize curPosition;
@synthesize delay;
@synthesize lastTime;


@end

@implementation Joystick



-(void) addStick:(id)itemId rect:(CGRect)rect
{
	if(!joystickAreas)
		joystickAreas = [[NSMutableArray alloc] init];

	JoystickArea *area  = [[JoystickArea alloc] init];

	int centerx = rect.size.width / 2 + rect.origin.x;
	int centery = rect.size.height / 2 + rect.origin.y;
	
	
	area.type = 1; // Stick
	area.joyId = itemId;
    area.bounds = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    area.center = CGPointMake(centerx,centery);
    area.curPosition = CGPointMake(centerx,centery);
    area.active = NO;
	area.delay = 0;
	area.lastTime = 0;
	
	[joystickAreas addObject:area];
}

-(void) addButton:(id)itemId rect:(CGRect)rect
{
	if(!joystickAreas)
		joystickAreas = [[NSMutableArray alloc] init];

	JoystickArea *area  = [[JoystickArea alloc] init];
	
	area.type = 2; // Button
	area.joyId = itemId;
    area.bounds = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    area.active = NO;
	area.delay = 0;
	area.lastTime = 0;
	
	[joystickAreas addObject:area];
}

-(id) getAreaForId:(id)itemId
{
	for (JoystickArea *area in joystickAreas)
		if(area.joyId == itemId) return area;
	
	return nil;
}


-(void) setDelayFor:(id)itemId delay:(float)delta
{
	JoystickArea *area = [self getAreaForId:itemId];
	if(area == nil) return;
	
	area.delay = delta;
}


-(bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	bool someTouch = NO;
	
	for (JoystickArea *area in joystickAreas)
	{
		if (area.active) continue;
		
		NSArray *allTouches = [touches allObjects];
		for (UITouch* t in allTouches)
		{
			CGPoint location = [t locationInView:[t view]];
			location = [[CCDirector sharedDirector] convertToGL:location];
			
			if (CGRectContainsPoint(area.bounds, location))
			{
				area.active = YES;
				area.touchAddress = (int)t;
				area.curPosition = CGPointMake(location.x, location.y);
				area.lastTime = 0;
				someTouch = YES;
			
			}
		}
		
	}
		
	return someTouch;
}

-(bool)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	bool someTouch = NO;
	for (JoystickArea *area in joystickAreas)
	{
		if (!area.active) continue;

		NSArray *allTouches = [touches allObjects];
		for (UITouch* t in allTouches)
			{
			if ((int)t == area.touchAddress)
				{
					
				if(area.type == 1) // Stick
					{
					CGPoint location = [t locationInView:[t view]];
					area.curPosition = [[CCDirector sharedDirector] convertToGL:location];
					someTouch = YES;
					}
					
				if(area.type == 2) // Button
					{
					CGPoint location = [t locationInView:[t view]];
					location = [[CCDirector sharedDirector] convertToGL:location];
					
					if (CGRectContainsPoint(area.bounds, location))
						someTouch = YES;
					else 
						area.active = NO;
						
					}
					
				}
			}
	}
  
	return someTouch;
}

-(bool)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	bool someTouch = NO;
	for (JoystickArea *area in joystickAreas)
	{
		if (!area.active) continue;
		
		NSArray *allTouches = [touches allObjects];
		for (UITouch* t in allTouches)
			{
			if ((int)t == area.touchAddress)
				{
				area.active = NO;
				area.curPosition = area.center;
				someTouch = YES;
				}
			}
	}
	return someTouch;
}





-(bool)isDown:(id)itemId
{
	JoystickArea *area = [self getAreaForId:itemId];
	if(area == nil) return NO;
	
	if(area.active)
	{
		double currentTime = CACurrentMediaTime(); 	
	
		if(currentTime - area.lastTime >= area.delay)
			{
			area.lastTime = currentTime;
			return YES;
			}
	}

	return NO;
}


-(CGPoint)getVelocity:(id)itemId
{
	JoystickArea *area = [self getAreaForId:itemId];
	if(area == nil) return CGPointMake(0,0);

	return CGPointMake(area.curPosition.x - area.center.x, 
					   area.curPosition.y - area.center.y);
}

-(CGPoint)getDegreeVelocity:(id)itemId
{
	JoystickArea *area = [self getAreaForId:itemId];
	if(area == nil) return CGPointMake(0,0);
	
	float dx = area.center.x - area.curPosition.x;
	float dy = area.center.y - area.curPosition.y;
	CGPoint vel = [self getVelocity:itemId];
	vel.y = sqrt((vel.x*vel.x + vel.y*vel.y));
	vel.x = atan2f(-dy, dx) * (180/3.14);
	
	return vel;
}





@end
