//
//  MMInspectorViewRelation.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 11/10/04.
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

#import "MMInspectorViewRelation.h"

#import "MMDocMainWinCont.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
#import "MMDocument.h"
//#import "MCPModel.h"
//#import "MCPClassDescription.h"
//#import "MCPAttribute.h"
//#import "MCPRelation.h"


@implementation MMInspectorViewRelation

#pragma mark Life Cycle
- (id) initWithFrame:(NSRect) frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil) {
// Add initialization code here
		NSRect		superRect = [self bounds];
		NSRect		subRect;
		NSPoint		origin;
		
		[NSBundle loadNibNamed:@"MMInspectorViewRelation" owner:self];
		[self addSubview:nibView];
		subRect = [nibView frame];
		origin = NSMakePoint(0,NSHeight(superRect) - NSHeight(subRect));
		[nibView setFrameOrigin:origin];
	//	NSLog(@"MAKING a new object : %@", self);
	}
//	NSLog(@"Just at the end of the -[MMInspectorViewRelation initWithFrame:], rc = %u", [self retainCount]);
	return self;
}


- (void) dealloc
{	
//	NSLog(@"DEALLOCATING object : %@", self);
	[relationController setContent:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark NSView Overload
//- (void)drawRect:(NSRect)rect;

#pragma mark Actions
/*
- (void) updateTable:(id) sender
{
//	[joinsTable reloadData];
}
*/

#pragma mark Nib Loading
- (void) awakeFromNib
{
//	NSLog(@"The nib file MMInspectorViewAttribute has finished being loaded!!");
}

#pragma mark Setters
- (void) setRelation:(MCPRelation *) iRelation
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPRelationChangedNotification object:nil];
	[relationController setContent:iRelation];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:MCPRelationChangedNotification object:iRelation];
//	[self updateTable:self];
}

#pragma mark Getters
- (MCPRelation	*) relation
{
	return (MCPRelation *)[relationController content];
}

- (NSView *) nibView
{
	return nibView;
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMInspectorViewRelation retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"in -[MMInspectorViewRelation release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
	return;
}

@end
