//
//  MMRelationInspectorWinCont.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 29/10/04.
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

#import "MMRelationInspectorWinCont.h"

#import "MMInspectorViewRelation.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
//#import "MCPRelation.h"

@implementation MMRelationInspectorWinCont

#pragma mark Life Cycle
- (id) init
{
	self = [super initWithWindowNibName:@"MMRelationInspectorWin"];
	if (self) {
	}
	return self;
}   

- (void) dealloc
{
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
	return [NSString stringWithFormat:@"%@ - Relation - %@", displayName, [[self relation] name]];
}

#pragma mark Actions
- (void) updateRelation:(id) sender
{
	[self synchronizeWindowTitleWithDocumentName];
}

#pragma mark Setters
- (void) setRelation:(MCPRelation *) iRelation
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPRelationChangedNotification object:nil];
	[relationInspectorView setRelation:iRelation];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:MCPRelationChangedNotification object:iRelation];
	[self updateRelation:self];
}

#pragma mark Getters
- (MCPRelation *) relation
{
	return [relationInspectorView relation];
}

@end
