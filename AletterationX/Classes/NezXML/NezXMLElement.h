//
//  NezXMLElement.h
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

@interface NezXMLElement : NSObject

@property (nonatomic, copy, readonly, getter = name) NSString *name;
@property (nonatomic, readonly, getter = isText) BOOL isText;
@property (nonatomic, copy, readonly, getter = content) NSString *content;
@property (nonatomic, copy, readonly, getter = raw) NSString *raw;
@property (nonatomic, copy, readonly, getter = parent) NezXMLElement *parent;
@property (nonatomic, copy, readonly, getter = next) NezXMLElement *next;
@property (nonatomic, copy, readonly, getter = prev) NezXMLElement *prev;
@property (nonatomic, copy, readonly, getter = children) NSArray *children;
@property (nonatomic, assign, readonly, getter = nodePtr) xmlNodePtr nodePtr;

+(instancetype)elementWithXMLNode:(xmlNodePtr)nodePtr;
-(instancetype)initWithXMLNode:(xmlNodePtr)nodePtr;

+(instancetype)elementWithXMLNodeName:(NSString*)nodeName;
-(instancetype)initWithXMLNodeName:(NSString*)nodeName;

-(void)deleteElement;

-(void)recursivelyDeleteAllElementsWithName:(NSString*)elementName;

-(void)addChild:(NezXMLElement*)child;
-(void)addPrevSibling:(NezXMLElement*)sibling;
-(void)addNextSibling:(NezXMLElement*)sibling;

@end
