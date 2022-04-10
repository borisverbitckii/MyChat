//
//  ASTextFieldNode.h
//  MyChat
//
//  Created by Boris Verbitsky on 01.04.2022.
//

#import <UIKit/UIKit.h>

//! Project version number for ASTextFieldNode.
FOUNDATION_EXPORT double ASTextFieldNodeVersionNumber;

//! Project version string for ASTextFieldNode.
FOUNDATION_EXPORT const unsigned char ASTextFieldNodeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ASTextFieldNode/PublicHeader.h>

#ifndef ASTextFieldNode_h
#define ASTextFieldNode_h

#import <AsyncDisplayKit/ASControlNode.h>
#import "ASTextFieldView.h"

@interface ASTextFieldNode : ASDisplayNode <UITextInputTraits>
@property (nonatomic, retain) ASDisplayNode* textFieldNode;
@property (nonatomic, retain) ASTextFieldView* textField;
@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@property (nonatomic, assign) NSString* placeholder;
@property (nonatomic, assign) NSString* text;
@property (nonatomic, assign) NSString* attributedText;
@property (nonatomic, assign) NSString* attributedPlaceholder;
@property (nonatomic, assign) UIFont* font;
@property (nonatomic, assign) UIColor* textColor;

@property (nonatomic, assign) UIEdgeInsets textContainerInset;
@end

#endif /* ASTextFieldNode_h */
