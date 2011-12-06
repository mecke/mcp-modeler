//
//  MMSourceExporterWinCont.m
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

#import "MMSourceExporterWinCont.h"

#import "MMDocument.h"
#import "MCPClassDescription.h"
#import "MMClassSourceExporter.h"

@implementation MMSourceExporterWinCont

#pragma mark Life Cycle
- (id) initWithExportedClass:(MCPClassDescription *) iExportedClass
{
	self = [super initWithWindowNibName:@"MMSourceExporterWin"];
	if (self) {
		exportedClass = iExportedClass;
		classExporter = [[MMClassSourceExporter alloc] initWithExportedClass:exportedClass];
	}
	return self;
}

- (void) dealloc
{
	[exportedClass release];
	[classExporter release];
	[super dealloc];
}


#pragma mark NSWindowConroller Override
- (void) windowDidLoad
{
	BOOL		theResult;

	[super windowDidLoad];
//	[classDescriptionController setContent:[[(MMDocument*)[self document] model] classDescription]];
	[modelController setContent:[(MMDocument *)[self document] model]];
#warning Should replace the following line : curently display a PROXY object...
//	NSLog(@"In -[MMSourceExporterWinCont windowDidLoad]; value of selected class description is : %@ -> %@", [exportedClass descriptionWithLocale:nil], [exportedClass name]);
//	theResult = [classDescriptionController setSelectedObjects:[NSArray arrayWithObject:exportedClass]];
//	NSLog(@"The result of the programmed selection is : %i", theResult);
//	NSLog(@"Selected object for the array controller is : %@", [classDescriptionController selectedObjects]);
	[classDescriptionSelector selectItemWithTitle:[exportedClass name]];
	return;
}


#pragma mark NSWindow delegate methods
- (BOOL) windowShouldClose:(id) sender
{
	return YES;
}

- (void) windowWillClose:(NSNotification *) aNotification
{
}


#pragma mark Actions
- (IBAction) doTheConversion:(id) sender
{
	NSLog(@"Action GO! called, should select the proper item in the menu...");
	NSLog(@"NOW, selected object from the menu is : %@, with object content : %@", [classDescriptionSelector selectedItem], [[[classDescriptionSelector selectedItem] representedObject] descriptionWithLocale:nil]);
	[classExporter setExportedClass:(MCPClassDescription *)[[classDescriptionSelector selectedItem] representedObject]];
	[headerTextView setString:[classExporter headerFile]];
	[methodTextView setString:[classExporter methodsFile]];
//	NSLog(@"\t\t\t\tand the selection of the array controller is : %@", [classDescriptionController selectedObjects]);
//	NSLog(@"\t\t\t\tFinally, the selectedClassDescription controller has object : %@ -> %@", [selectedClassDescription content], [(MCPClassDescription*)[selectedClassDescription content] name]);
	return;
}

- (IBAction) exportToFiles:(id) sender
{
	NSOpenPanel			*directoryChooser = [NSOpenPanel openPanel];

	[directoryChooser setTitle:@"Choose a directory where to save the sources"];
	[directoryChooser setPrompt:@"Choose"];
	[directoryChooser setNameFieldLabel:@"Save sources in : "];
	[directoryChooser setCanChooseDirectories:YES];
	[directoryChooser setCanChooseFiles:NO];
	[directoryChooser setAllowsMultipleSelection:NO];
	[directoryChooser setResolvesAliases:YES];
	[directoryChooser setCanCreateDirectories:YES];
	[directoryChooser beginSheetForDirectory:nil file:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(destinationDirectoryChoice:returnCode:contextInfo:) contextInfo:nil];
	NSLog(@"Just after calling the directory choosing sheet ... still in exportToFiles: method");
//	NSLog(@"The current selection in the classDescriptionController (NSArrayController) is : %@", theSelectedObjects);
//	NSLog(@"In more details this is :");
//	for (i=0; [theSelectedObjects count] != i; ++i) {
//		NSLog(@"Object %u is\n%@", i, [(MCPClassDescription *)[theSelectedObjects objectAtIndex:i] descriptionWithLocale:nil]);
//	}
//	NSLog(@"Testing the MCPModel description from the current model :\n%@", [[exportedClass model] descriptionWithLocale:nil]);
//	NSLog(@"Testing the MCPClassDescription description from the 1st class of the model :\n%@", [[[[exportedClass model] classDescriptions] objectAtIndex:0] descriptionWithLocale:nil]);

	return;
}


#pragma mark Menu Control
#pragma mark Naming New Items
#pragma mark Call back messages
- (void) destinationDirectoryChoice:(NSOpenPanel *) sheet returnCode:(int) returnCode contextInfo:(void *) contextInfo
{
	NSLog(@"Sheet calling is %@, return code is %i and context is %p", sheet, returnCode, contextInfo);
	if (NSOKButton == returnCode) {
		NSString				*theDirectory = (NSString *)[[sheet filenames] objectAtIndex:0];
		NSArray				*theSelectedObjects = [classDescriptionController selectedObjects];
		unsigned int		i;
		
		for (i = 0; [theSelectedObjects count] != i; ++i) {
			MCPClassDescription		*theClassDescription = (MCPClassDescription *)[theSelectedObjects objectAtIndex:i];
			NSString						*filename;
			NSString						*fileContent;
			
			[classExporter setExportedClass:theClassDescription];
			filename = [NSString stringWithFormat:@"%@/%@.m", theDirectory, [theClassDescription name]];
			fileContent = [classExporter methodsFile];
			[fileContent writeToFile:filename atomically:YES];
			filename = [NSString stringWithFormat:@"%@/%@.h", theDirectory, [theClassDescription name]];
			fileContent = [classExporter headerFile];
			[fileContent writeToFile:filename atomically:YES];
		}
//		[[self window] performClose:self]; // Does not work, because here the window is still in modal mode, because the sheet is not off yet...
// Uses the NSRunLoop to wait untill out of the window modal mode to send the performClose: message :
		[[NSRunLoop currentRunLoop] performSelector:@selector(performClose:) target:[self window] argument:self order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	}
	return;
}

#pragma mark Setters
- (void) setExportedClass:(MCPClassDescription *) iExportedClass
{
	if (iExportedClass != exportedClass) {
		[exportedClass release];
		exportedClass = [iExportedClass retain];
		if (classExporter) {
			[classExporter setExportedClass:exportedClass];
		}
		else {
			classExporter = [[MMClassSourceExporter alloc] initWithExportedClass:exportedClass];
		}
	}
}


#pragma mark Getters
- (MCPClassDescription *) exportedClass
{
	return exportedClass;
}

- (MMClassSourceExporter *) classExporter
{
	return classExporter;
}


@end
