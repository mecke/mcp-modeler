//
//  MMDocument.h
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


#import <Cocoa/Cocoa.h>

#import "MCPModel.h"
#import "MMDBModelImporter.h"

#import "MCPKit_bundled/MCPEntrepriseNotifications.h"

@class MMDocMainWinCont;

/*
 NSString    *MCPModelChangedNotification;
 NSString    *MCPClassDescriptionChangedNotification;
 NSString    *MCPAttributeChangedNotification;
 NSString    *MCPRelationChangedNotification;
 */
@interface MMDocument : NSDocument
{
	MCPModel					*model;
	MMDBModelImporter		*importer;
	MMDocMainWinCont     *docMainWinCont;
}

#pragma mark Life Cycle
- (id) init;
- (void) dealloc;

#pragma mark Controlling windows
- (NSArray *) makeWindowControllers;
- (void) windowControllerDidLoadNib:(NSWindowController *) aController;

#pragma mark Archiving interface
- (NSData *) dataRepresentationOfType:(NSString *) aType;
- (BOOL) loadDataRepresentation:(NSData *) data ofType:(NSString *) aType;

#pragma mark Menu Control
- (BOOL) validateMenuItem:(NSMenuItem *) anItem;

#pragma mark Actions
- (IBAction) updateModel:(id) sender;
- (IBAction) importModelFromDBServer:(id) sender;
- (IBAction) showSourceExporterWindow:(id) sender;
- (IBAction) logModelOut:(id) sender;

#pragma mark Setters

#pragma mark Getters
- (MCPModel *) model;
- (MMDBModelImporter *) importer;
- (MMDocMainWinCont *) docMainWinCont;

@end
