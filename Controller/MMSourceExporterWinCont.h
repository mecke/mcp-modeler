//
//  MMSourceExporterWinCont.h
//  MCPModeler
//
//  Created by Serge Cohen on 01/12/04.
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

@class MCPClassDescription;
@class MMClassSourceExporter;

@interface MMSourceExporterWinCont : NSWindowController {
	IBOutlet NSTextView				*headerTextView;
	IBOutlet NSTextView				*methodTextView;
	IBOutlet NSObjectController	*modelController;
	IBOutlet NSArrayController		*classDescriptionController;
	IBOutlet NSPopUpButton			*classDescriptionSelector;
	
// Instance variable to make the actual conversion:
	MCPClassDescription				*exportedClass;
	MMClassSourceExporter			*classExporter;
}

#pragma mark Life Cycle
- (id) initWithExportedClass:(MCPClassDescription *) iExportedClass;
- (void) dealloc;

#pragma mark NSWindowConroller Override
- (void) windowDidLoad;

#pragma mark NSWindow delegate methods
- (BOOL) windowShouldClose:(id) sender;
- (void) windowWillClose:(NSNotification *) aNotification;

#pragma mark Actions
- (IBAction) doTheConversion:(id) sender;
- (IBAction) exportToFiles:(id) sender;

#pragma mark Menu Control
#pragma mark Naming New Items
#pragma mark Call back messages
- (void) destinationDirectoryChoice:(NSOpenPanel *) sheet returnCode:(int) returnCode contextInfo:(void *) contextInfo;

#pragma mark Setters
- (void) setExportedClass:(MCPClassDescription *) iExportedClass;

#pragma mark Getters
- (MCPClassDescription *) exportedClass;
- (MMClassSourceExporter *) classExporter;

@end
