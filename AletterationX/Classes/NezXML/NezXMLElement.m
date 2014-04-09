//
//  NezXMLElement.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezXMLElement.h"

@implementation NezXMLElement {
	xmlNodePtr _nodePtr;
}

+(instancetype)elementWithXMLNode:(xmlNodePtr)nodePtr {
	return [[self alloc] initWithXMLNode:nodePtr];
}

-(instancetype)initWithXMLNode:(xmlNodePtr)nodePtr {
	if ((self = [super init])) {
		_nodePtr = nodePtr;
	}
	return self;
}

+(instancetype)elementWithXMLNodeName:(NSString*)nodeName {
	return [[self alloc] initWithXMLNodeName:nodeName];
}

-(instancetype)initWithXMLNodeName:(NSString*)nodeName {
	if ((self = [super init])) {
		_nodePtr = xmlNewNode(0, BAD_CAST [nodeName cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	return self;
}

-(NSString*)name {
	if (_nodePtr && _nodePtr->name) {
		return [NSString stringWithCString:(const char *)_nodePtr->name encoding:NSUTF8StringEncoding];
	}
	return nil;
}

-(BOOL)isText {
	if ([self.name isEqualToString:@"text"]) {
		return YES;
	}
	return NO;
}

-(NSString*)content {
	if (_nodePtr && _nodePtr->content && _nodePtr->content != (xmlChar *)-1) {
		NSString *content = [NSString stringWithCString:(const char *)_nodePtr->content encoding:NSUTF8StringEncoding];
		[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		return content;
	}
	return nil;
}

-(NSArray*)attributes {
	xmlAttr *attribute = _nodePtr->properties;
	if (attribute)	{
      while (attribute) {
			attribute = attribute->next;
		}
	}
	return nil;
}

-(NSString*)raw {
	if (_nodePtr) {
		xmlBufferPtr buffer = xmlBufferCreate();
		xmlNodeDump(buffer, _nodePtr->doc, _nodePtr, 0, 0);
		
		NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
		xmlBufferFree(buffer);
		
		return rawContent;
	}
	return nil;
}

-(xmlNodePtr)nodePtr {
	return _nodePtr;
}

-(NezXMLElement*)parent {
	if (_nodePtr && _nodePtr->parent) {
		return [NezXMLElement elementWithXMLNode:_nodePtr->parent];
	}
	return nil;
}

-(NezXMLElement*)next {
	if (_nodePtr) {
		return [NezXMLElement elementWithXMLNode:_nodePtr->next];
	}
	return nil;
}

-(NezXMLElement*)prev {
	if (_nodePtr) {
		return [NezXMLElement elementWithXMLNode:_nodePtr->prev];
	}
	return nil;
}

-(NSArray*)children {
	NSMutableArray *children = [NSMutableArray array];
	
	for (xmlNodePtr node = _nodePtr->children; node; node = node->next) {
		[children addObject:[NezXMLElement elementWithXMLNode:node]];
	}
	return children;
}

-(void)unlink {
	if (_nodePtr && _nodePtr->parent) {
		xmlUnlinkNode(_nodePtr);
	}
}

-(void)addChild:(NezXMLElement*)child {
	if (child.nodePtr && _nodePtr) {
		[child unlink];
		xmlAddChild(_nodePtr, child.nodePtr);
	}
}

-(void)addPrevSibling:(NezXMLElement*)sibling {
	if (sibling.nodePtr && _nodePtr) {
		[sibling unlink];
		xmlAddPrevSibling(_nodePtr, sibling.nodePtr);
	}
}

-(void)addNextSibling:(NezXMLElement*)sibling {
	if (sibling.nodePtr && _nodePtr) {
		[sibling unlink];
		xmlAddNextSibling(_nodePtr, sibling.nodePtr);
	}
}

-(void)recursivelyDeleteAllElementsWithName:(NSString*)elementType {
	for (NezXMLElement *element in self.children) {
		[element recursivelyDeleteAllElementsWithName:elementType];
	}
	if ([self.name isEqualToString:elementType]) {
		[self deleteElement];
	}
}

-(void)deleteElement {
	if (_nodePtr) {
		[self unlink];
		xmlFreeNode(_nodePtr);
		_nodePtr = NULL;
	}
}

@end
