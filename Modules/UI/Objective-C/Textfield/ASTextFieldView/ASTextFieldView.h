//
//  ASTextFieldView.h
//  MyChat
//
//  Created by Boris Verbitsky on 01.04.2022.
//

#ifndef ASTextFieldView_h
#define ASTextFieldView_h

#import <UIKit/UIKit.h>

#import <AsyncDisplayKit/ASBaseDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASTextFieldView : UITextField
@property (nonatomic, assign) UIEdgeInsets textContainerInset;
@end

NS_ASSUME_NONNULL_END

#endif /* ASTextFieldView_h */
