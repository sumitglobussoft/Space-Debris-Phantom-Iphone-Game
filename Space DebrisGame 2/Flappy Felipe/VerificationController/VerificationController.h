#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>


#define IS_IOS6_AWARE (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1)

#define ITMS_PROD_VERIFY_RECEIPT_URL        @"https://buy.itunes.apple.com/verifyReceipt"
#define ITMS_SANDBOX_VERIFY_RECEIPT_URL     @"https://sandbox.itunes.apple.com/verifyReceipt";

#define KNOWN_TRANSACTIONS_KEY              @"knownIAPTransactions"
#define ITC_CONTENT_PROVIDER_SHARED_SECRET  @"436cdff613ec4eb588e9454f88a8ed46"

char* base64_encode(const void* buf, size_t size);
void * base64_decode(const char* s, size_t * data_len);

@protocol VerificationControllerDelegate <NSObject>
@property (nonatomic, strong) id <VerificationControllerDelegate> delegate;
@end
typedef void (^VerifyCompletionHandler)(BOOL success);

@interface VerificationController : NSObject
{
        NSMutableDictionary * _completionHandlers;
    NSUserDefaults * userDefault;
    NSMutableDictionary *transactionsReceiptStorageDictionary;
}

+ (VerificationController *) sharedInstance;


// Checking the results of this is not enough.
// The final verification happens in the connection:didReceiveData: callback within
// this class.  So ensure IAP feaures are unlocked from there.
- (void)verifyPurchase:(SKPaymentTransaction *)transaction completionHandler:(VerifyCompletionHandler)completionHandler;

@end
