/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// virtual joystick class
//
// Creates a virtual touch joystick within the bounds passed in. 
// Default mode is that any press begin in the bounds area becomes
// the center of the joystick. Call setCenter if you want a static
// joystick center position instead. Querry getCurrentVelocity
// for an X,Y offset value, or getCurrentDegreeVelocity for a
// degree and velocity value.

// Version 1.1 by neofar - Modificada la clase base del Joystick para añadir
//    soporte para varios sticks y para botones, ademas se permite configurar                                                                                              
//    un retardo en los clicks de los botones.
//
// http://idev.ofcode.com
//

#import <Foundation/Foundation.h>

@interface JoystickArea : NSObject 
{
	unsigned char type; // 0 - Stick, 1 - Button
	id joyId;			// id for item 'Joystick1', 'ButtonA', 'X' ...
	
	int touchAddress;   // touch id
	bool active;		// active

	CGRect bounds;
	CGPoint center;
	CGPoint curPosition;

	double delay;
	double lastTime;
}

@property (readwrite, assign) unsigned char type; 
@property (readwrite, assign) id joyId; 
@property (readwrite, assign) int touchAddress;   
@property (readwrite, assign) bool active;		
@property (readwrite, assign) CGRect bounds;
@property (readwrite, assign) CGPoint center;
@property (readwrite, assign) CGPoint curPosition;
@property (readwrite, assign) double delay;
@property (readwrite, assign) double lastTime;
@end


@interface Joystick : NSObject 
{
	NSMutableArray *joystickAreas;
}


-(void) addStick:(id)itemId rect:(CGRect)rect;
-(void) addButton:(id)itemId rect:(CGRect)rect;
-(void) setDelayFor:(id)itemId delay:(float)delta;

-(bool) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(bool) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(bool) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

-(bool)isDown:(id)itemId;
-(CGPoint)getVelocity:(id)itemId;
-(CGPoint)getDegreeVelocity:(id)itemId;

@end
