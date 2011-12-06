//
//  MMDBModelImportWinCont.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 20/09/04.
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

#import "MMDBModelImportWinCont.h"

#import "MMDBModelImporter.h"

@implementation MMDBModelImportWinCont

#pragma mark Life Cycle
- (id) init
{
	self = [super initWithWindowNibName:@"MMDBModelImportWin"];
	if (self) {
// So far nothing special to do.
	//	NSLog(@"MAKING a new object : %@", self);
	}
	return self;
}

/*
- (id) retain
{
	NSLog(@"Called once more retain on MMDBModelImportWinCont... retainCount is now : %u (will be %u)", [self retainCount], [self retainCount] + 1);
	return [super retain];
}

- (oneway void) release
{
	NSLog(@"Called release on MMDBModelImportWinCont... retainCount is now : %u (will be %u)", [self retainCount], [self retainCount] - 1 );
	[super release];
}
*/

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
	[importer release];
//	NSLog(@"The MMDBModelImportWinCont was released...");
	[super dealloc];
}

#pragma mark NSWindowConroller Override
- (void) windowDidLoad
{
	[super windowDidLoad];
	[stepDescription setStringValue:@"Step 1 : Setting import options and choosing DB model"];
	[stepViews selectTabViewItemWithIdentifier:@"setup"];
}

#pragma mark NSWindow delegate methods
- (BOOL) windowShouldClose:(id) sender
{
#pragma warning Should implement a check if tries to dismiss in the middle of an import setup.
	return YES;
}

- (void) windowWillClose:(NSNotification *) aNotification
{
	[importerController unbind:@"contentObject"];
	return;
}

#pragma mark Actions
- (IBAction) connectToDB:(id) sender
{
//	[[[self window] firstResponder] resignFirstResponder];
	[[self window] endEditingFor:[[self window] firstResponder]];
	if (![importer connect]) {
		NSLog(@" in -[MMDBModelImportWinCont connectToDB:], connection to DB did NOT WORK!\n\n");
		return;
	}
//	NSLog(@" in -[MMDBModelImportWinCont connectToDB:], connection to DB was OK!");
	if (0 == [importer getTablesFromDB]) {
		NSLog(@" in -[MMDBModelImportWinCont connectToDB:], NO tables were retrieved from the DB!\n\n");
		return;
	}
//	NSLog(@" in -[MMDBModelImportWinCont connectToDB:], retrieved %u tables from the DB.", [[importer tables] count]);
	[stepDescription setStringValue:@"Step 2 : Selecting the classDescriptions to import"];
	[stepViews selectTabViewItemWithIdentifier:@"chooser"];
	return;
}

- (IBAction) unconnectToDB:(id) sender
{
	[stepDescription setStringValue:@"Step 1 : Setting import options and choosing DB model"];
	[stepViews selectTabViewItemWithIdentifier:@"setup"];
	return;
}

- (IBAction) setupNextTable:(id) sender
{
	if ([importer prepareNextTable]) {
		[importer prepareForImportCurrentTable];
		[stepDescription setStringValue:[NSString stringWithFormat:@"Step 3 : Preparing %@ for import", [[importer currentTable] valueForKey:@"tableName"]]];
//		[stepDescription setStringValue:@"Step 3 : Setting import options and choosing DB model"];
		[stepViews selectTabViewItemWithIdentifier:@"classDescriptions"];
		return;
	}
	else {
		[stepDescription setStringValue:@"Step 4 : Importing model"];
		[stepViews selectTabViewItemWithIdentifier:@"final"];
	}
}

- (IBAction) setupPreviousTable:(id) sender
{
	if ([importer preparePreviousTable]) {
		[importer prepareForImportCurrentTable];
		[stepDescription setStringValue:[NSString stringWithFormat:@"Step 3 : Preparing %@ for import", [[importer currentTable] valueForKey:@"tableName"]]];
//		[stepDescription setStringValue:@"Step 3 : Setting import options and choosing DB model"];
		[stepViews selectTabViewItemWithIdentifier:@"classDescriptions"];
	}
	else {
		[stepDescription setStringValue:@"Step 2 : Selecting the classDescriptions to import"];
		[stepViews selectTabViewItemWithIdentifier:@"chooser"];
		return;
	}
}

- (IBAction) importTablesAtLast:(id) sender
{
	[importer importTables];
	[self setShouldCloseDocument:NO];
	[[self window] performClose:self];
	[[self document] removeWindowController:self];
	return;
}

#pragma mark Call back messages

#pragma mark Setters
- (void) setImporter:(MMDBModelImporter *) iImporter
{
	if (iImporter != importer) {
		[importer release];
		importer = [iImporter retain];
	}
}

#pragma mark Getters
- (MMDBModelImporter *) importer
{
	return importer;
}


@end
