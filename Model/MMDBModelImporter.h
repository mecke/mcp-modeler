//
//  MMDBModelImporter.h
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

#import <MCPKit_bundled/MCPKit_bundled.h>

@class MCPModel;

@interface MMDBModelImporter : NSObject {
// General instances:
	MCPModel						*model;			// The model that we should import TO
	NSString						*classPrefix;	// The prefix for the classes
	NSString						*tablePrefix;	// The prefix used in the DB
	BOOL							overwrite;		// Should we overwrite the current model
	NSMutableArray				*tables;			// Array of the names of the tables in the DB (with corresponding class names)
	NSMutableDictionary		*currentTable;	// Dictionary holding the columns... of the current table
	
// DB server specific:
	MCPConnection				*connection;	// The connection to the DB
	NSString						*protocol;		// The type of DB used
	NSString						*host;			// The hostname (including port after :, ie localhost:3121)
	NSString						*username;		// The user name to log to the DB
	NSString						*password;		// The password (if required) to login to DB
	NSString						*dbName;			// The database name
}

#pragma mark Class Messages
+ (void) initialize;

#pragma mark Life Cycle
- (id) initWithModel:(MCPModel *) iModel;
- (void) dealloc;

#pragma mark NSCoding protocol
- (id) initWithCoder:(NSCoder *) decoder;
- (void) encodeWithCoder:(NSCoder *) encoder;

#pragma mark Utility methods
- (NSString *) classNameFromTableName:(NSString *) tableName;
- (NSString *) attributeNameFromColumnName:(NSString *) columnName;

#pragma mark Actions
- (BOOL) connect;
- (unsigned int) getTablesFromDB;
- (BOOL) prepareNextTable;
- (BOOL) preparePreviousTable;
- (BOOL) prepareForImportCurrentTable;
- (BOOL) importTables;

#pragma mark Setters
- (void) setModel:(MCPModel *) iModel;
- (void) setClassPrefix:(NSString *) iClassPrefix;
- (void) setTablePrefix:(NSString *) iTablePrefix;
- (void) setOverwrite:(BOOL) iOverwrite;
- (void) setProtocol:(NSString *) iProtocol;
- (void) setHost:(NSString *) iHost;
- (void) setUsername:(NSString *) iUsername;
- (void) setPassword:(NSString *) iPassword;
- (void) setDbName:(NSString *) iDbName;

#pragma mark Getters
- (MCPModel *) model;
- (NSString *) classPrefix;
- (NSString *) tablePrefix;
- (BOOL) overwrite;
- (NSMutableArray *) tables;
- (unsigned int) countOfTables;
- (NSMutableDictionary *) objectInTablesAtIndex:(unsigned int) index;
- (NSMutableDictionary *) currentTable;
- (MCPConnection *) connection;
- (NSString *) protocol;
- (NSString	*) host;
- (NSString	*) username;
- (NSString	*) password;
- (NSString	*) dbName;

#pragma mark For logging and debugging
- (NSString *) description;

@end
