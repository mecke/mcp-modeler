//
//  MMInspectorViewClassDescription.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 13/09/04.
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

#import "MMInspectorViewClassDescription.h"


#import "MMDocMainWinCont.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
#import "MMDocument.h"
//#import "MCPModel.h"
//#import "MCPClassDescription.h"
//#import "MCPAttribute.h"
//#import "MCPRelation.h"


@implementation MMInspectorViewClassDescription

#pragma mark Life Cycle
- (id) initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
// Add initialization code here
		NSRect		superRect = [self bounds];
		NSRect		subRect;
		NSPoint		origin;
		
		[NSBundle loadNibNamed:@"MMInspectorViewClassDescription" owner:self];
		[self addSubview:nibView];
		subRect = [nibView frame];
		origin = NSMakePoint(0,NSHeight(superRect) - NSHeight(subRect));
		[nibView setFrameOrigin:origin];
	//	NSLog(@"MAKING a new object : %@", self);
	}
//	NSLog(@"Just at the end of the -[MMInspectorViewClassDescription initWithFrame:], rc = %u", [self retainCount]);
	return self;
}

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
//	[classDescription release];
	[classDescriptionController setContent:nil];
	[super dealloc];
}

#pragma mark NSView Overload
//- (void)drawRect:(NSRect)rect;
/*
#pragma mark NSTableView datasource and delegate
- (int) numberOfRowsInTableView:(NSTableView *) aTableView
{
	if (aTableView == attributeTable) {
//      return [[classDescription attributes] count];
		return [classDescription countOfAttributes];
	}
	if (aTableView == relationTable) {
//      return [[classDescription relations] count];
		return [classDescription countOfRelations];
	}
	return 0;
}

- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex
{
// Case of the table of attributes:
	if (aTableView == attributeTable) {
//      MCPAttribute    *attribute = (MCPAttribute *)[[classDescription attributes] objectAtIndex:rowIndex];
		MCPAttribute		*attribute = [classDescription objectInAttributesAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"attribute"]) {
			return [attribute name];
		}
		if ([[aTableColumn identifier] isEqualToString:@"identity"]) {
			return [NSNumber numberWithBool:[attribute isPartOfIdentity]];
		}
		if ([[aTableColumn identifier] isEqualToString:@"key"]) {
			return [NSNumber numberWithBool:[attribute isPartOfKey]];
		}
		return nil;
	}
// Case of the table of relations:
	if (aTableView == relationTable) {
//      MCPRelation     *relation = (MCPRelation *)[[classDescription relations] objectAtIndex:rowIndex];
		MCPRelation		*relation = [classDescription objectInRelationsAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"relation"]) {
			return [relation name];
		}
		if ([[aTableColumn identifier] isEqualToString:@"destination"]) {
			return [[relation destination] name];
		}
		return nil;
	}
	return nil;
}

- (void) tableView:(NSTableView *) aTableView setObjectValue:(id) anObject forTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex
{
// Case of the table of attributes:
	if (aTableView == attributeTable) {
//      MCPAttribute    *attribute = (MCPAttribute *)[[classDescription attributes] objectAtIndex:rowIndex];
		MCPAttribute    *attribute = [classDescription objectInAttributesAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"attribute"]) {
			[attribute setName:anObject];
			return;
		}
		if ([[aTableColumn identifier] isEqualToString:@"identity"]) {
			[attribute setIsPartOfIdentity:[anObject boolValue]];
			return;
		}
		if ([[aTableColumn identifier] isEqualToString:@"key"]) {
			[attribute setIsPartOfKey:[anObject boolValue]];
			return;
		}
		return;
	}
// Case of the table of relations:
	if (aTableView == relationTable) {
//      MCPRelation     *relation = (MCPRelation *)[[classDescription relations] objectAtIndex:rowIndex];
		MCPRelation     *relation = [classDescription objectInRelationsAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"relation"]) {
			[relation setName:anObject];
			return;
		}
//      if ([[aTableColumn identifier] isEqualToString:@"destination"]) {
//         return [[relation destination] name];
//      }
		return;
	}
	return;
}
*/

#pragma mark Nib Loading
- (void) awakeFromNib
{
//	NSLog(@"The nib file MMInspectorViewClassDescription has finished being loaded!!");
}

#pragma mark Actions
- (IBAction) classDescriptionChanged:(id) sender
{
//	[attributeTable reloadData];
//	[relationTable reloadData];
}

#pragma mark Setters
- (void) setClassDescription:(MCPClassDescription *) iClassDescription
{
/*	if (iClassDescription != classDescription) {
		if (classDescription) {
			[classDescription release];
			[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPClassDescriptionChangedNotification object:classDescription];
		}
		classDescription = [iClassDescription retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(classDescriptionChanged:) name:MCPClassDescriptionChangedNotification object:classDescription];
		[attributeTable reloadData];
		[relationTable reloadData];
// Taking care of the controller.
	}
*/
	[classDescriptionController setContent:iClassDescription];
}


#pragma mark Getters
- (MCPClassDescription *) classDescription
{
//	return classDescription;
	return (MCPClassDescription *)[classDescriptionController content];
}

- (NSView *) nibView
{
	return nibView;
}

#pragma mark Temporary for debugging
- (id) valueForUndefinedKey:(NSString *) key
{
	NSLog(@"valueForUndefinedKey send to MMInspectorViewClassDescription for key : %s. Out of curiosity, class description = %@", key, [self classDescription]);
	return nil;
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMInspectorViewClassDescription retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"in -[MMInspectorViewClassDescription release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
	return;
}


@end
