//
//  MMDocMainWinCont.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 09/08/04.
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

#import "MMDocMainWinCont.h"

#import "MMInspectorViewModel.h"
#import "MMInspectorViewClassDescription.h"
#import "MMInspectorViewAttribute.h"
#import "MMInspectorViewRelation.h"

#import "MMModelInspectorWinCont.h"
#import "MMClassDescriptionInspectorWinCont.h"
#import "MMAttributeInspectorWinCont.h"
#import "MMRelationInspectorWinCont.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"
#import "MMDocument.h"
//#import "MCPKit_bundled/MCPModel.h"
//#import "MCPKit_bundled/MCPClassDescription.h"
//#import "MCPKit_bundled/MCPAttribute.h"


static NSString *MMDocMainWinToolbarIdentifier = @"Main Window toolbar";


@implementation MMDocMainWinCont

#pragma mark Life Cycle
- (id) init
{
	self = [super initWithWindowNibName:@"MMDocMainWin"];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModel:) name:MCPModelChangedNotification object:[(MMDocument *)[self document] model]];
	//	NSLog(@"MAKING a new object : %@", self);
	}
	return self;
}

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[modelInspectorView setModel:nil];
	[classDescriptionInspectorView setClassDescription:nil];
	[attributeInspectorView	setAttribute:nil];
	[relationInspectorView setRelation:nil];
	[super dealloc];
}


#pragma mark NSWindowConroller Override
- (void) windowDidLoad
{
	[super windowDidLoad];
// Add things here:
	[self updateModel:self];
	[modelInspectorView setModel:model];
	return;
}

#pragma mark Actions
- (IBAction) updateModel:(id) sender
{
	model = [(MMDocument *)[self document] model];
	[modelList reloadData];
	return;
}

- (IBAction) addClassDescription:(id) sender
{
	int				newClassDescriptionIndex = 0;
	id					selectedItem = [modelList itemAtRow:[modelList selectedRow]];
	
	if ([[modelList selectedRowIndexes] count] != 1) { // The selection should be unique here.
		return;
	}
	if ([selectedItem isKindOfClass:[MCPAttribute class]]) { // Get the corresponding class description.
		selectedItem = [(MCPAttribute *)selectedItem classDescription]; 
	}
	if ([selectedItem isKindOfClass:[MCPRelation class]]) { // Get the corresponding class description.
		selectedItem = [(MCPRelation *)selectedItem origin];
	}
	if ([selectedItem isKindOfClass:[MCPClassDescription class]]) { // Get the proper index for the insertion of the new one.
#warning Should modify that to use the [MCPModel indexOfClassDescription:] method
		newClassDescriptionIndex = [[model classDescriptions] indexOfObjectIdenticalTo:selectedItem] + 1;
	}
//	[model addNewClassDescriptionWithName:@"NewClassDescription" inPosition:newClassDescriptionIndex];
	[model addNewClassDescriptionWithName:[self nameForNewClassDescription] inPosition:newClassDescriptionIndex];
	return;
}

- (IBAction) addAttribute:(id) sender
{
//   int            theIndex = [modelList selectedRow];
	id									theItem = [modelList itemAtRow:[modelList selectedRow]];
	int								newAttributeIndex = 0;
	MCPClassDescription			*theClassDescription = nil;
	MCPAttribute					*theAttribute;
	
	if ([[modelList selectedRowIndexes] count] != 1) { // The selection should be unique here.
		return;
	}
	if ([theItem isKindOfClass:[MCPModel class]]) { // Can not add attribute to the Model...
		return;
	}
	
	if ([theItem isKindOfClass:[MCPAttribute class]]) { // Get the class description right and the index:
		theClassDescription = [(MCPAttribute *)theItem classDescription];
#warning Have to rewrite next line with proper method from MCPClassDescription (still not perfect...)
		newAttributeIndex = [theClassDescription indexOfAttribute:theItem] + 1;
//		newAttributeIndex = [[theClassDescription attributes] indexOfObjectIdenticalTo:theItem] + 1;
	}
	if ([theItem isKindOfClass:[MCPRelation class]]) { // Get the proper class description (attribute added at the end)
		theClassDescription = [(MCPRelation *)theItem origin];
	}
	if ([theItem isKindOfClass:[MCPClassDescription class]]) { // Get the proper class description (attribute added at the end)
		theClassDescription = (MCPClassDescription *)theItem;
	}
	if (! theClassDescription) {
		return;
	}
//   [theClassDescription addNewAttributeWithName:@"NewAttribute"];
	[theClassDescription addNewAttributeWithName:[self nameForNewAttributeInClassDescription:theClassDescription] inPosition:newAttributeIndex];
	return;
}

- (IBAction) addRelation:(id) sender
{
	id									theItem = [modelList itemAtRow:[modelList selectedRow]];
	int								newRelationIndex = 0;
	MCPClassDescription			*theClassDescription = nil;
	MCPRelation						*theRelation;
//	MCPAttribute					*theAttribute;
	
	if ([[modelList selectedRowIndexes] count] != 1) { // The selection should be unique here.
		return;
	}
	if ([theItem isKindOfClass:[MCPModel class]]) { // Can not add attribute to the Model...
		return;
	}
	
	if ([theItem isKindOfClass:[MCPRelation class]]) { // Get the class description right and the index:
		theClassDescription = [(MCPRelation *)theItem origin];
		newRelationIndex = [theClassDescription indexOfRelation:theItem] + 1;
	}
	if ([theItem isKindOfClass:[MCPAttribute class]]) { // Get the proper class description (attribute added at the end)
		theClassDescription = [(MCPAttribute *)theItem classDescription];
	}
	if ([theItem isKindOfClass:[MCPClassDescription class]]) { // Get the proper class description (attribute added at the end)
		theClassDescription = (MCPClassDescription *)theItem;
	}
	if (! theClassDescription) {
		return;
	}
//   [theClassDescription addNewAttributeWithName:@"NewAttribute"];
//	[theClassDescription addNewAttributeWithName:[self nameForNewAttributeInClassDescription:theClassDescription] inPosition:newAttributeIndex];
//	[theClassDescription addNewDirectRelationTo:self name:[self nameForNewRelationInClassDescription:theClassDescription] inPosition:newRelationIndex];
	[theClassDescription addNewRelationTo:theClassDescription name:[self nameForNewRelationInClassDescription:theClassDescription] inPostion:newRelationIndex];
	return;
}

- (IBAction) addItem:(id) sender
{
//	MMDocument  *document = (MMDocument *)[self document];
	id          selectedItem;
	
	if ([[modelList selectedRowIndexes] count] != 1) { // The selection should be unique here.
		return;
	}
	selectedItem = [modelList itemAtRow:[modelList selectedRow]];
	if (([selectedItem isKindOfClass:[MCPModel class]]) || (([selectedItem isKindOfClass:[MCPClassDescription class]]) && (![modelList isItemExpanded:selectedItem]))) { // The selected object is a model, or a closed class description
	// Add a new class description :
		[self addClassDescription:sender];
		return;
	}
	if ((([selectedItem isKindOfClass:[MCPClassDescription class]]) && ([modelList isItemExpanded:selectedItem])) || ([selectedItem isKindOfClass:[MCPAttribute class]])) { // Selected item is an open class description or an attribute
	// Add a new attribute :
		[self addAttribute:sender];
		return;
	}
	if ([selectedItem isKindOfClass:[MCPRelation class]]) { // the selected object is a relation and we add a new relation
		[self addRelation:sender];
		return;
	}
	NSLog(@"In -[MMDocMainWinCont addItem]... we should not arrive here, ever....");
	return;
}

- (IBAction) removeItem:(id) sender
{
	MMDocument		*document = (MMDocument *)[self document];
	NSIndexSet		*selectedRows = [modelList selectedRowIndexes];
	unsigned int	index;

	if ([selectedRows count] == 0) { // Need at least one item selected.
		return;
	}
	for (index = [selectedRows lastIndex]+1; index != [selectedRows firstIndex]; --index) {
		if ([selectedRows containsIndex:(index - 1)]) {
			id			selectedItem = [modelList itemAtRow:(index - 1)];

			[selectedItem retain];
			NSLog(@"In -[MCPDocMainWinCont removeItem:%@], retain count of the object to remove is : %u (most likely 2)", selectedItem, [selectedItem retainCount]);
			if ([selectedItem isKindOfClass:[MCPClassDescription class]]) {
				[model removeObjectFromClassDescriptionsAtIndex:[model indexOfClassDescription:selectedItem]];
//				continue;
			}
			if ([selectedItem isKindOfClass:[MCPAttribute class]]) {
				MCPClassDescription		*theCD = [(MCPAttribute *)selectedItem classDescription];

				[theCD removeObjectFromAttributesAtIndex:[theCD indexOfAttribute:selectedItem]];
//				continue;
			}
			if ([selectedItem isKindOfClass:[MCPRelation class]]) {
				MCPClassDescription		*theCD = [(MCPRelation *)selectedItem origin];

				[theCD removeObjectFromRelationsAtIndex:[theCD indexOfRelation:selectedItem]];
//				continue;
			}
			NSLog(@"In -[MCPDocMainWinCont removeItem:%@], retain count of the object to remove is : %u (most likely 1, just before last release)", selectedItem, [selectedItem retainCount]);
			[selectedItem release];
		}
	}
	
	return;
}

- (IBAction) openInspector:(id) sender
{
	MMDocument		*document = (MMDocument *)[self document];
	NSIndexSet		*selectedRowIndexes = [modelList selectedRowIndexes];
	unsigned int	numSelectedRows = [selectedRowIndexes count];
	unsigned int	index;
	
	if (0 == [[modelList selectedRowIndexes] count]) { // The selection should be unique here.
		return;
	}
	for (index = [selectedRowIndexes firstIndex]; 1+[selectedRowIndexes lastIndex] != index; ++index) {
		if ([selectedRowIndexes containsIndex:index]) {
			id          selectedItem = [modelList itemAtRow:index];
			
			if ([selectedItem isKindOfClass:[MCPModel class]]) {
				MMModelInspectorWinCont    *newWinCont = [[MMModelInspectorWinCont alloc] init];
				
				[newWinCont setShouldCloseDocument:NO];
				[document addWindowController:newWinCont];
//				[newWinCont setModel:selectedItem];
//				[newWinCont setValue:selectedItem forKey:@"model"];
				[newWinCont showWindow:self];
				[newWinCont setModel:(MCPModel *)selectedItem];
				[newWinCont release];
				continue;
			}
			if ([selectedItem isKindOfClass:[MCPClassDescription class]]) {
				MMClassDescriptionInspectorWinCont   *newWinCont = [[MMClassDescriptionInspectorWinCont alloc] init];
				
				[newWinCont setShouldCloseDocument:NO];
				[document addWindowController:newWinCont];
				[newWinCont showWindow:self];
//				[newWinCont setValue:selectedItem forKey:@"classDescription"];
				[newWinCont setClassDescription:(MCPClassDescription *)selectedItem];
				[newWinCont release];
				continue;
			}
			if ([selectedItem isKindOfClass:[MCPAttribute class]]) {
				MMAttributeInspectorWinCont   *newWinCont = [[MMAttributeInspectorWinCont alloc] init];
				
				[newWinCont setShouldCloseDocument:NO];
				[document addWindowController:newWinCont];
				[newWinCont showWindow:self];
//				[newWinCont setValue:selectedItem forKey:@"attribute"];
				[newWinCont setAttribute:(MCPAttribute *)selectedItem];
				[newWinCont release];
				continue;
			}
			if ([selectedItem isKindOfClass:[MCPRelation class]]) {
				MMRelationInspectorWinCont		*newWinCont = [[MMRelationInspectorWinCont alloc] init];

				[newWinCont setShouldCloseDocument:NO];
				[document addWindowController:newWinCont];
				[newWinCont showWindow:self];
				[newWinCont setRelation:(MCPRelation *)selectedItem];
				[newWinCont release];
				continue;
			}
		}
	}
	return;
}

#pragma mark Menu Control
- (BOOL) validateMenuItem:(NSMenuItem *) anItem
{
	unsigned int	numberOfSelectedRows = [[modelList selectedRowIndexes] count];
	id					selectedItem = nil;
	
	if (1 == numberOfSelectedRows) {
		selectedItem = [modelList itemAtRow:[modelList selectedRow]];
	}
	if (@selector(removeItem:) == [anItem action]) {
		return (0 != numberOfSelectedRows);
	}
	if (@selector(addItem:) == [anItem action]) {
		return (1 == numberOfSelectedRows);
	}
	if (@selector(addClassDescription:) == [anItem action]) {
		return ([selectedItem isKindOfClass:[MCPModel class]]) || ([selectedItem isKindOfClass:[MCPClassDescription class]]);
	}
	if ((@selector(addAttribute:) == [anItem action]) || (@selector(addRelation:) == [anItem action])) {
		return ([selectedItem isKindOfClass:[MCPClassDescription class]]) || ([selectedItem isKindOfClass:[MCPAttribute class]]);
	}
	if (@selector(openInspector:) == [anItem action]) {
		return (0 != numberOfSelectedRows);
	}
	return YES;
}

#pragma mark Naming New Items
- (NSString *) nameForNewClassDescription
{
	NSMutableString	*theName = [NSMutableString stringWithString:@"NewClassDescription"];
	unsigned int		i;

	if (NSNotFound == [model indexOfClassDescription:theName]) {
		return theName;
	}
	for (i=1; 1000 != i; ++i) {
		[theName deleteCharactersInRange:NSMakeRange(0,[theName length])];
		[theName appendFormat:@"NewClassDescription%i", i];
		if (NSNotFound == [model indexOfClassDescription:theName]) {
			return theName;
		}
	}
	return @"NewClassDescriptionXXXX";
}

- (NSString *) nameForNewAttributeInClassDescription:(MCPClassDescription *) iClassDescription
{
	NSMutableString	*theName = [NSMutableString stringWithString:@"NewAttribute"];
	unsigned int		i;
	
	if (NSNotFound == [iClassDescription indexOfAttribute:theName]) {
		return theName;
	}
	for (i=1; 1000 != i; ++i) {
		[theName deleteCharactersInRange:NSMakeRange(0,[theName length])];
		[theName appendFormat:@"NewAttribute%i", i];
		if (NSNotFound == [iClassDescription indexOfAttribute:theName]) {
			return theName;
		}
	}
	return @"NewAttributeXXXX";
}

- (NSString *) nameForNewRelationInClassDescription:(MCPClassDescription *) iClassDescription
{
	NSMutableString	*theName = [NSMutableString stringWithString:@"NewRelation"];
	unsigned int		i;
	
	if (NSNotFound == [iClassDescription indexOfRelation:theName]) {
		return theName;
	}
	for (i=1; 1000 != i; ++i) {
		[theName deleteCharactersInRange:NSMakeRange(0,[theName length])];
		[theName appendFormat:@"NewRelation%i", i];
		if (NSNotFound == [iClassDescription indexOfRelation:theName]) {
			return theName;
		}
	}
	return @"NewRelationXXXX";	
}

#pragma mark Call back messages
//- (void) openCodeFile:(NSOpenPanel *) sheet returnCode:(int) returnCode contextInfo: (void *) contextInfo;


#pragma mark Data Source for OutlineView
- (int) outlineView:(NSOutlineView *) outlineView numberOfChildrenOfItem:(id) item 
{
	if (item == nil) {
		return 1;
	}
	if ([item isKindOfClass:[MCPModel class]]) {
//      return [[(MCPModel *)item classDescriptions] count];
		return [(MCPModel *)item countOfClassDescriptions];
	}
	if ([item isKindOfClass:[MCPClassDescription class]]) {
//      return [[(MCPClassDescription *)item attributes] count];
		return [(MCPClassDescription *)item countOfAttributes] + [(MCPClassDescription *)item countOfRelations];
	}
	return 0;
}



- (BOOL) outlineView:(NSOutlineView *) outlineView isItemExpandable:(id) item
{
	return ([item isKindOfClass:[MCPModel class]]) || ([item isKindOfClass:[MCPClassDescription class]]);
}

- (id) outlineView:(NSOutlineView *) outlineView child:(int) index ofItem:(id) item
{
	if (item == nil) {
		return model;
	}
	if ([item isKindOfClass:[MCPModel class]]) {
//      return [[(MCPModel *)item classDescriptions] objectAtIndex:index];
		return [(MCPModel *)item objectInClassDescriptionsAtIndex:index];
	}
	if ([item isKindOfClass:[MCPClassDescription class]]) {
//      return [[(MCPClassDescription *)item attributes] objectAtIndex:index];
		MCPClassDescription		*theClassDescription = (MCPClassDescription *)item;

		if (index < [theClassDescription countOfAttributes]) {
			return [theClassDescription objectInAttributesAtIndex:index];			
		}
		return [theClassDescription objectInRelationsAtIndex:(index - [theClassDescription countOfAttributes])];
	}
	return nil;
}

- (id) outlineView:(NSOutlineView *) outlineView objectValueForTableColumn:(NSTableColumn *) tableColumn byItem:(id) item
{
	if ([[tableColumn identifier] isEqualToString:@"name"]) {
		/*
		 if ([item isKindOfClass:[MCPModel class]]) {
			 return [(MCPModel *)item name];
		 }
		 if ([item isKindOfClass:[MCPClassDescription class]]) {
			 return [(MCPClassDescription *)item className];
		 }
		 */
		if ([item isKindOfClass:[MCPRelation class]]) { // Display it in bold (default system font do NOT have italic...)
//		if ([item isKindOfClass:[MCPAttribute class]]) { // Display it in bold
			NSColor				*theColor = [NSColor blueColor];
			NSFontManager		*theFontM = [NSFontManager sharedFontManager];
			NSFont				*theBolfFont = [theFontM convertFont:[NSFont systemFontOfSize:[NSFont systemFontSize]] toHaveTrait:NSBoldFontMask];

			return [[[NSAttributedString alloc] initWithString:[item name] attributes:[NSDictionary dictionaryWithObjectsAndKeys: theBolfFont, NSFontAttributeName, theColor, NSForegroundColorAttributeName, nil]] autorelease];
		}
	// Default case :
		return [item name];
	}
	if ([[tableColumn identifier] isEqualToString:@"externalName"]) {
		if (([item isKindOfClass:[MCPClassDescription class]]) || ([item isKindOfClass:[MCPAttribute class]])) {
			return [item externalName];
		}
	}
	return @"";
}

- (void) outlineView:(NSOutlineView *) outlineView setObjectValue:(id) object forTableColumn:(NSTableColumn *) tableColumn byItem:(id) item
{
	if ([[tableColumn identifier] isEqualToString:@"name"]) {
		[item setName:object];
	}
	if ([[tableColumn identifier] isEqualToString:@"externalName"]) {
		if (([item isKindOfClass:[MCPClassDescription class]]) || ([item isKindOfClass:[MCPAttribute class]])) {
			[item setExternalName:object];
		}
	}
}

#pragma mark Delegate for OutlineView (NSTableView delegate)
- (void) outlineViewSelectionDidChange:(NSNotification *) aNotification
{
	id       selectedItem = [modelList itemAtRow:[modelList selectedRow]];
	
	if ([selectedItem isKindOfClass:[MCPModel class]]) {
		[inspectorTabView selectTabViewItemWithIdentifier:@"model"];
		[relationInspectorView setRelation:nil];
		[classDescriptionInspectorView setClassDescription:nil];
		[attributeInspectorView setAttribute:nil];
	}
	if ([selectedItem isKindOfClass:[MCPClassDescription class]]) {
		[classDescriptionInspectorView setClassDescription:selectedItem];
		[inspectorTabView selectTabViewItemWithIdentifier:@"classDescription"];
		[attributeInspectorView setAttribute:nil];
		[relationInspectorView setRelation:nil];
	}
	if ([selectedItem isKindOfClass:[MCPAttribute class]]) {
		[attributeInspectorView setAttribute:selectedItem];
		[inspectorTabView selectTabViewItemWithIdentifier:@"attribute"];
		[classDescriptionInspectorView setClassDescription:nil];
		[relationInspectorView setRelation:nil];
	}
	if ([selectedItem isKindOfClass:[MCPRelation class]]) {
		[relationInspectorView setRelation:selectedItem];
		[inspectorTabView selectTabViewItemWithIdentifier:@"relation"];
		[classDescriptionInspectorView setClassDescription:nil];
		[attributeInspectorView setAttribute:nil];
	}
}

/*
- (void) outlineView:(NSOutlineView *) outlineView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn item:(id) item
{
	if ([item isKindOfClass:[MCPRelation class]]) {
	}
}
*/

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMDocMainWinCont retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"STARTING the release of MMDocMainWinCont !!!");
//	NSLog(@"in -[MMDocMainWinCont release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
//	NSLog(@"FINISHED the release of MMDocMainWinCont !!!!");
	return;
}

#pragma mark Setters
#pragma mark Getters
- (MCPClassDescription *) selectedClassDescription
{
	unsigned int	numberOfSelectedRows = [[modelList selectedRowIndexes] count];
	id					selectedItem = nil;
	
	if (1 == numberOfSelectedRows) {
		selectedItem = [modelList itemAtRow:[modelList selectedRow]];
	}
	else {
		return nil;
	}
	if ([selectedItem isKindOfClass:[MCPModel class]]) {
		return nil;
	}
	if ([selectedItem isKindOfClass:[MCPClassDescription class]]) {
		return selectedItem;
	}
	if ([selectedItem isKindOfClass:[MCPAttribute class]]) {
		return [(MCPAttribute *)selectedItem classDescription];
	}
	if ([selectedItem isKindOfClass:[MCPRelation class]]) {
		return [(MCPRelation *)selectedItem origin];
	}
	return nil;
}



@end
