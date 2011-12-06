//
//  MMDocument.m
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

#import "MMDocument.h"

#import "MMDocMainWinCont.h"
#import "MMDBModelImportWinCont.h"
#import "MMSourceExporterWinCont.h"

@interface MMDocument (Private)

#pragma mark Setters(Private)
- (void) setModel:(MCPModel *) iModel;
- (void) setImporter:(MMDBModelImporter *) iImporter;

@end

@implementation MMDocument

#pragma mark Life cycle
- (id) init
{
	self = [super init];
	if (self) {    
// Add your subclass-specific initialization here.
// If an error occurs here, send a [self release] message and return nil.
		MCPModel		*theModel = [[MCPModel alloc] initWithName:@"Untitled"];

		[self setModel:theModel];
		[theModel release];
	//	NSLog(@"MAKING a new object : %@", self);
//		[self setImporter:[[MMDBModelImporter alloc] initWithModel:[self model]];
	}
	return self;
}

- (void) dealloc
{
//	NSLog(@"DEALLOCATING object : %@", self);
// Release all iVars:
	[model release];
	[importer release];
// Then dealloc super:
	[super dealloc];
}

#pragma mark Controlling windows
- (NSArray *) makeWindowControllers
/*" Make the proper window : the main window for the document. "*/
{
	MMDocMainWinCont     *theWinCont;
	
	theWinCont = [[MMDocMainWinCont allocWithZone:[self zone]] init];
	[theWinCont setShouldCloseDocument:YES];
	[self addWindowController: theWinCont];
	[theWinCont release];
	docMainWinCont = theWinCont;
	return [self windowControllers];
}


- (void) windowControllerDidLoadNib:(NSWindowController *) aController
{
	[super windowControllerDidLoadNib:aController];
// Add any code here that needs to be executed once the windowController has loaded the document's window.
}

#pragma mark Archiving interface.
- (NSData *) dataRepresentationOfType:(NSString *) aType
{
// Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	NSMutableData        *theData = [[NSMutableData alloc] init];
	NSKeyedArchiver      *theArchive = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	NSData               *theRet;
	
// Does not work to get a refernce of model inside the archive :
//   [model encodeWithCoder:theArchive];
// Works ok when needing internal reference to model :
	[theArchive setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[theArchive encodeObject:model forKey:@"MCPmodel"];
	[theArchive encodeObject:importer forKey:@"MMimporter"];
//   NSLog(@"in MMDocument dataRepresentationOfType, model = %@ (pointer = %p)", model, model);
	[theArchive finishEncoding];
	theRet = [NSData dataWithData:theData];
	[theArchive release];
	[theData release];
	return theRet;
}

- (BOOL) loadDataRepresentation:(NSData *) data ofType:(NSString *) aType
{
// Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
	if ([aType isEqualToString:@"MCPModel"]) {
		NSKeyedUnarchiver       *theArchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		
//      [model release];
//      model = ;
		
// Does not work to get a refernce of model inside the archive :
//      [self setModel:[[MCPModel alloc] initWithCoder:theArchive]];
// Works ok when needing internal reference to model :
		[self setValue:[theArchive decodeObjectForKey:@"MCPmodel"] forKey:@"model"];
		[self setValue:[theArchive decodeObjectForKey:@"MMimporter"] forKey:@"importer"];
		[theArchive release];
//      [[NSNotificationCenter defaultCenter] postNotification:MCPModelChangedNotification];
		[[NSNotificationCenter defaultCenter] postNotificationName:MCPModelChangedNotification object:nil];
		return YES;
	}
	return NO;
}

#pragma mark Menu Control
- (BOOL) validateMenuItem:(NSMenuItem *) anItem
{
	if (@selector(showSourceExporterWindow:) == [anItem action]) {
		return YES;
//		return (nil == [docMainWinCont selectedClassDescription]) ? NO : YES;
	}
	return YES;
}

#pragma mark Actions
- (IBAction) updateModel:(id) sender
{
	[self updateChangeCount:NSChangeDone];
}

- (IBAction) importModelFromDBServer:(id) sender
{
	unsigned int					i;
	MMDBModelImportWinCont		*winCont;

	for (i = 0; i < [[self windowControllers] count]; ++i) {
		if ([[[self windowControllers] objectAtIndex:i] isKindOfClass:[MMDBModelImportWinCont class]]) {
			winCont = [[self windowControllers] objectAtIndex:i];
			[[winCont window] makeKeyAndOrderFront:self];
			return;
		}
	}
	if (! importer) {
		[self setImporter:[[MMDBModelImporter alloc] initWithModel:[self model]]];
//      [self setValue:[[MMDBModelImporter alloc] initWithModel:[self model]] forKey:@"importer"];
	}
	winCont = [[MMDBModelImportWinCont alloc] init];
//	NSLog(@"After init retain count is %u", [winCont retainCount]);
	[self addWindowController:winCont];
//	NSLog(@"After adding to document retain count is %u", [winCont retainCount]);
	[winCont release];
//	NSLog(@"After releasing retain count is %u", [winCont retainCount]);
//   [winCont setDocument:self];
	[winCont setShouldCloseDocument:NO];
//   [winCont setValue:importer forKey:@"importer"];
	[winCont setImporter:importer];
	[winCont showWindow:self];
//	NSLog(@"Close to end of action, retain count is %u", [winCont retainCount]);
//	[winCont autorelease];
	return;
}

- (IBAction) showSourceExporterWindow:(id) sender
{
	unsigned int					i;
	MMSourceExporterWinCont		*winCont;
	
	for (i = 0; i < [[self windowControllers] count]; ++i) {
		if ([[[self windowControllers] objectAtIndex:i] isKindOfClass:[MMSourceExporterWinCont class]]) {
			winCont = [[self windowControllers] objectAtIndex:i];
			[[winCont window] makeKeyAndOrderFront:self];
			return;
		}
	}
	winCont = [[MMSourceExporterWinCont alloc] initWithExportedClass:[docMainWinCont selectedClassDescription]];
	[self addWindowController:winCont];
	[winCont release];
	[winCont setShouldCloseDocument:NO];
	[winCont showWindow:self];
	return;
}

- (IBAction) logModelOut:(id) sender
{
	NSArray			*classDescriptions = [model classDescriptions];
	unsigned int	i;

	NSLog(@"In -[MMDocument logModelOut:], so logging the model (is it a proxy : %@ ) to the output (using -[ description]):\n%@\nNow trying to use directly%%@ :\n%@\nUsing explicit -[ descriptionWithLocale:] :\n%@\nFinally the pointer to model is %p", ([model isProxy]) ? @"YES" : @"NO", [model description], model, [model descriptionWithLocale:nil], model);
	for (i = 0; [classDescriptions count] != i; ++i) {
		NSLog(@"Logging class description %u : %@", i, [[classDescriptions objectAtIndex:i] descriptionWithLocale:nil]);
	}
}

#pragma mark Setters

#pragma mark Getters
- (MCPModel *) model
{
	return model;
}

- (MMDBModelImporter *) importer
{
	return importer;
}

- (MMDocMainWinCont *) docMainWinCont
{
	return docMainWinCont;
}

#pragma mark For debugging the retain counting
- (id) retain
{
	[super retain];
//	NSLog(@"in -[MMDocument retain] for %@, count is %u (after retain).", self, [self retainCount]);
	return self;
}

- (void) release
{
//	NSLog(@"****STARTING the release of MMDocument !!!");
//	NSLog(@"in -[MMDocument release] for %@, count is %u (after release).", self, [self retainCount]-1);
	[super release];
//	NSLog(@"****FINISHED the release of MMDocument !!!!");
	return;
}


@end

@implementation MMDocument (Private)

#pragma mark Setters(Private)
- (void) setModel:(MCPModel *) iModel
{
	if (iModel != model) {
		if (model) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:MCPModelChangedNotification object:model];
			[model release];
		}
		model = [iModel retain];
//      NSLog(@"in MMDocument setModel, model = %@ (pointer = %p)", model, model);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModel:) name:MCPModelChangedNotification object:model];
	}
}

- (void) setImporter:(MMDBModelImporter *) iImporter
{
	if (iImporter != importer) {
		[importer release];
		importer = [iImporter retain];
	}
}

@end

