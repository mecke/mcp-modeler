//
//  MMClassDescriptionInspectorWinCont.m
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

#import "MMClassDescriptionInspectorWinCont.h"

#import "MMInspectorViewClassDescription.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
//#import "MCPClassDescription.h"


@implementation MMClassDescriptionInspectorWinCont

#pragma mark Life Cycle
- (id) init
{
	self = [super initWithWindowNibName:@"MMClassDescriptionInspectorWin"];
	if (self) {
//      [self setValue:[(MMDocument *)[self document] model] forKey:@"model"];
//      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModel:) name:MCPModelChangedNotification object:[(MMDocument *)[self document] model]];
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
//   NSLog(@"In -[MMClassDescriptionInspectorWinCont windowDidLoad], now the IBOutlet classDescriptionInspctorView is : %@.", classDescriptionInspectorView);
	return;
}

- (NSString *) windowTitleForDocumentDisplayName:(NSString *) displayName
{
	return [NSString stringWithFormat:@"%@ - Class Description - %@", displayName, [[self classDescription] name]];
}

#pragma mark Actions
- (void) updateClassDescription:(id) sender
{
	[self synchronizeWindowTitleWithDocumentName];
}

#pragma mark Setters
- (void) setClassDescription:(MCPClassDescription *) iClassDescription
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPClassDescriptionChangedNotification object:nil];
	[classDescriptionInspectorView setClassDescription:iClassDescription];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClassDescription:) name:MCPClassDescriptionChangedNotification object:iClassDescription];
	[self updateClassDescription:self];
}

#pragma mark Getters
- (MCPClassDescription *) classDescription
{
	return [classDescriptionInspectorView classDescription];
}

@end
