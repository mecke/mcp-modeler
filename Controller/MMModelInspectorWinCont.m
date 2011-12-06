//
//  MMModelInspectorWinCont.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 18/09/04.
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

#import "MMModelInspectorWinCont.h"

#import "MMDocument.h"
#import "MMInspectorViewModel.h"

#import "MCPModel.h"


@implementation MMModelInspectorWinCont

#pragma mark Life Cycle
- (id) init;
{
	self = [super initWithWindowNibName:@"MMModelInspectorWin"];
	if (self) {
// Delay it for the windowDidLoad: message.
//		[self setModel:[(MMDocument *)[self document] model]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModel:) name:MCPModelChangedNotification object:[(MMDocument *)[self document] model]];
//		NSLog(@"MAKING a new object %@, retain count is %u", self, [self retainCount]);
	}
	return self;
}

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark NSWindowConroller Override
- (void) windowDidLoad
{
	[super windowDidLoad];
// Add things here:
	return;
}

- (NSString *) windowTitleForDocumentDisplayName:(NSString *) displayName
{
	return [NSString stringWithFormat:@"%@ - Model - %@", displayName, [[self model] name]];
}

#pragma mark Actions
- (void) updateModel:(id) sender
{
	[self synchronizeWindowTitleWithDocumentName];
}

#pragma mark Setters
- (void) setModel:(MCPModel *) iModel
{
//	model = iModel;
// Make sure we update the inspector view as well...
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPModelChangedNotification object:nil];
	[modelInspectorView setModel:iModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModel:) name:MCPModelChangedNotification object:iModel];
	[self updateModel:self];
}

#pragma mark Getters
- (MCPModel *) model
{
	return [modelInspectorView model];
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
	NSLog(@"in -[MMModelInspectorWinCont retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
	NSLog(@"in -[MMModelInspectorWinCont release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
	return;
}

- (id) autorelease
{
	NSLog(@"in -[MMModelInspectorWinCont autorelease] for %@, count is %u (when it will be released, not yet).", self, [self retainCount]-1);
	[super autorelease];
	return;
}

@end
