//
//  MMInspectorViewAttribute.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 14/09/04.
//  Copyright 2004 Serge Cohen. All rights reserved.
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  For a copy of the GNU General Public License, visit <http://www.gnu.org/> or
//  write to the Free Software Foundation, Inc., 59 Temple Place--Suite 330,
//  Boston, MA 02111-1307, USA.
//
//  More info at <http://mysql-cocoa.sourceforge.net/>
//

#import "MMInspectorViewAttribute.h"

#import "MMDocMainWinCont.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
#import "MMDocument.h"
//#import "MCPModel.h"
//#import "MCPClassDescription.h"
//#import "MCPAttribute.h"
//#import "MCPRelation.h"


@implementation MMInspectorViewAttribute

#pragma mark Life Cycle
- (id) initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
// Add initialization code here
		NSRect		superRect = [self bounds];
		NSRect		subRect;
		NSPoint		origin;
		
		[NSBundle loadNibNamed:@"MMInspectorViewAttribute" owner:self];
		[self addSubview:nibView];
		subRect = [nibView frame];
		origin = NSMakePoint(0,NSHeight(superRect) - NSHeight(subRect));
		[nibView setFrameOrigin:origin];
	//	NSLog(@"MAKING a new object : %@", self);
	}
//	NSLog(@"Just at the end of the -[MMInspectorViewAttribute initWithFrame:], rc = %u", [self retainCount]);
	return self;
}

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
	[attributeController setContent:nil];
//	[attribute release];
	[super dealloc];
}

#pragma mark NSView Overload
//- (void)drawRect:(NSRect)rect;

#pragma mark Nib Loading
- (void) awakeFromNib
{
//	NSLog(@"The nib file MMInspectorViewAttribute has finished being loaded!!");
}

#pragma mark Setters
- (void) setAttribute:(MCPAttribute *) iAttribute
{
/*
	if (iAttribute != attribute) {
		[attribute release];
		attribute = [iAttribute retain];
	}
 */
	[attributeController setContent:iAttribute];
}

#pragma mark Getters
- (MCPAttribute *) attribute
{
	return (MCPAttribute *)[attributeController content];
}

- (NSView *) nibView
{
	return nibView;
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMInspectorViewAttribute retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"in -[MMInspectorViewAttribute release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
	return;
}


@end
