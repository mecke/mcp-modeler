//
//  MMAttributeInspectorWinCont.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 19/09/04.
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

#import "MMAttributeInspectorWinCont.h"

#import "MMInspectorViewAttribute.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
//#import "MCPAttribute.h"

@implementation MMAttributeInspectorWinCont

#pragma mark Life Cycle
- (id) init
{
	self = [super initWithWindowNibName:@"MMAttributeInspectorWin"];
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
	return [NSString stringWithFormat:@"%@ - Attribute - %@", displayName, [[self attribute] name]];
}

#pragma mark Actions
- (void) updateAttribute:(id) sender
{
	[self synchronizeWindowTitleWithDocumentName];
}

#pragma mark Setters
- (void) setAttribute:(MCPAttribute *) iAttribute
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPAttributeChangedNotification object:nil];
	[attributeInspectorView setAttribute:iAttribute];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAttribute:) name:MCPAttributeChangedNotification object:iAttribute];
	[self updateAttribute:self];
}


#pragma mark Getters
- (MCPAttribute *) attribute
{
	return [attributeInspectorView attribute];
}

@end
