//
//  TLDisclosureBar.h
//  Created by Jonathan Dann and on 20/10/2008.
//	Copyright (c) 2008, espresso served here.
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, 
//	are permitted provided that the following conditions are met:
//
//	Redistributions of source code must retain the above copyright notice, this list 
//	of conditions and the following disclaimer.
//
//	Redistributions in binary form must reproduce the above copyright notice, this list 
//	of conditions and the following disclaimer in the documentation and/or other materials 
//	provided with the distribution.
//
//	Neither the name of the espresso served here nor the names of its contributors may be
//	used to endorse or promote products derived from this software without specific prior 
//	written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//	OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
//	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
//	IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
//	OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Cocoa/Cocoa.h>
#import "TLGradientView.h"

@interface TLDisclosureBar : TLGradientView <NSCoding>{
@private
	NSButton *_disclosureButton;
	NSImageView *_imageViewLeft;
	NSImageView *_imageViewRight;
	NSTextField *_labelField;
}
@property(readonly,retain) NSImageView *imageViewLeft;
@property(readonly,retain) NSImageView *imageViewRight;
@property(readonly,retain) NSButton *disclosureButton;
@property(readonly,retain) NSTextField *labelField;
- (id)initWithFrame:(NSRect)frame expanded:(BOOL)expanded;
- (id)initWithFrame:(NSRect)frame leftImage:(NSImage *)leftImage rightImage:(NSImage *)rightImage label:(NSString *)label expanded:(BOOL)expanded;
- (void)setLeftImage:(NSImage *)image;
- (void)setRightImage:(NSImage *)image;
- (void)setLabel:(NSString *)label;
@end
