//
//  UIView+FindFirstResponder.h
//
//  Class Description:
//  This class over-rides the super UIView Class. In this we are adding a method to identify the first responder
//  from the subViews on the view. It can be itself also as firstResponder.

@interface UIView (FindFirstResponder) 


/**
 * - (UIView *)findFirstResponder:
 * This method searches for the firstResponder from its subViews and return reference of the firstResponder object if found any.
 * If no firstRespnder object was found then it returns nil. If itself is an firsResponder then it return its own reference.
 */
- (UIView *)findFirstResponder;

/**
 * - (void)registerToResignKeyboard:
 * This method registers the view for tap gesture.
 * Upon detecting tap, it will find if there is any subview which is firstresponder and will resignFirstResponder
 */
- (void)registerToResignKeyboard;

@end
