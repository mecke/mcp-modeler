//
//  MMDocument.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 09/09/04.
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

#import "MMInspectorViewModel.h"

#import "MMDocMainWinCont.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
#import "MMDocument.h"
//#import "MCPModel.h"
//#import "MCPClassDescription.h"
//#import "MCPAttribute.h"


@implementation MMInspectorViewModel

#pragma mark Life Cycle
- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
// Add initialization code here
		NSRect		superRect = [self bounds];
		NSRect		subRect;
		NSPoint		origin;
		
		[NSBundle loadNibNamed:@"MMInspectorViewModel" owner:self];
		[self addSubview:nibView];
		subRect = [nibView frame];
		origin = NSMakePoint(0,NSHeight(superRect) - NSHeight(subRect));
		[nibView setFrameOrigin:origin];
//		[self release];
//		[self release];
	//	NSLog(@"MAKING a new object : %@", self);
	}
//	NSLog(@"Just at the end of the -[MMInspectorViewModel initWithFrame:], rc = %u", [self retainCount]);
	return self;
}

- (void) dealloc
{	
//	NSLog(@"DEALLOCATING object : %@", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[modelController release];
//	[nibView removeFromSuperview];
//	[model release]; // just in case...
//	model = nil;
//	[self setModel:nil];
	[super dealloc];
}

#pragma mark NSView Overload
/*- (void)drawRect:(NSRect)rect
{
}
*/

#pragma mark Nib Loading
- (void) awakeFromNib
{
//	NSLog(@"The nib file MMInspectorViewModel has finished being loaded!!");
}

#pragma mark Setters
- (void) setModel:(MCPModel *) iModel
{
	[modelController setContent:iModel];
/*
//   NSLog(@"In MMInspectorViewModel : setModel");
	if (iModel != model) {
//      NSLog(@"Model has changed... will set fields appropriately");
		[model release];
		model = [iModel retain];
//      [modelNameField setStringValue:[model name]];
//      [usesInnoDBButton setState:([model usesInnoDBTables]) ? NSOnState : NSOffState];
	}
*/
}

#pragma mark Getters
- (MCPModel *) model
{
	return (MCPModel *)[modelController content];
}

- (NSView *) nibView
{
	return nibView;
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMInspectorViewModel retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"in -[MMInspectorViewModel release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
	return;
}

@end
