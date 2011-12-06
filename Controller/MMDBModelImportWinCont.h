//
//  MMDBModelImportWinCont.h
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

#import <Cocoa/Cocoa.h>

@class MMDBModelImporter;

@interface MMDBModelImportWinCont : NSWindowController {
// View connections:
	IBOutlet	NSTextField					*stepDescription;
	IBOutlet	NSTabView					*stepViews;
	IBOutlet NSButton						*nextButtonClassDescriptions;
	IBOutlet NSButton						*prevButtonClassDescriptions;
	
// Model conenctions:
	IBOutlet MMDBModelImporter			*importer;
	
// Persistence state:
	NSMutableArray							*selectedTables;
	unsigned int                     currentTable;
	
// Bug fixing:
	IBOutlet NSObjectController		*importerController;
}

#pragma mark Life Cycle
- (id) init;
- (void) dealloc;

#pragma mark NSWindowConroller Override
- (void) windowDidLoad;

#pragma mark NSWindow delegate methods
- (BOOL) windowShouldClose:(id) sender;
- (void) windowWillClose:(NSNotification *) aNotification;

#pragma mark Actions
- (IBAction) connectToDB:(id) sender;
- (IBAction) unconnectToDB:(id) sender;
//- (IBAction) prepareForTablesSetup:(id) sender;
- (IBAction) setupNextTable:(id) sender;
- (IBAction) setupPreviousTable:(id) sender;
- (IBAction) importTablesAtLast:(id) sender;

#pragma mark Call back messages

#pragma mark Setters
- (void) setImporter:(MMDBModelImporter *) iImporter;

#pragma mark Getters
- (MMDBModelImporter *) importer;

@end
