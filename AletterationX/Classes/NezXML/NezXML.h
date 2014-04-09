//
//  NezXML.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import "NezXMLElement.h"

@interface NezXML : NSObject

+(instancetype)xmlDocWithData:(NSData*)data encoding:(NSString*)encoding;
+(instancetype)xmlDocWithData:(NSData*)data;
+(instancetype)htmlDocWithData:(NSData*)data encoding:(NSString *)encoding;
+(instancetype)htmlDocWithData:(NSData*)data;

-(instancetype)initWithXMLData:(NSData*)data encoding:(NSString*)encoding;
-(instancetype)initWithXMLData:(NSData*)data;
-(instancetype)initWithHTMLData:(NSData*)data encoding:(NSString *)encoding;
-(instancetype)initWithHTMLData:(NSData*)data;

-(NSArray*)performXPathQuery:(NSString*)query;
-(void)deleteNodesWithXPathQuery:(NSString*)query;
-(void)recursivelyDeleteAllElementsWithName:(NSString*)elementType;

@end
