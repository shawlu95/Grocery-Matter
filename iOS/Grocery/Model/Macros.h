//
//  Macros.h
//  Grocery
//
//  Created by Xiao on 7/8/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define DEVELOPMENT 1
#define TESTAPI 0

#define KEY_CACHED_USER_ID @"cachedUserID"
#define KEY_CACHED_PASSWORD @"cachedPassword"
#define KEY_CACHED_IP @"cachedIP"

#define KEY_ID              @"id"
#define KEY_TIME            @"time"
#define KEY_PRICE           @"price"
#define KEY_CURRENCY        @"currency"
#define KEY_PRICECNY        @"priceCNY"
#define KEY_COUNT           @"count"
#define KEY_NAME            @"name"
#define KEY_TYPE            @"type"
#define KEY_LAST_MODIFIED   @"lastModified"
#define KEY_CREATED         @"created"
#define KEY_USER_ID         @"userID"
#define KEY_PASSWORD        @"password"
#define KEY_INSTALLATION_ID @"installationID"
#define KEY_DID_LOG_IN      @"didLogIn"

/* Add new category:
 (1) define type
 (2) define localized string
 (3) Add to list
 (4) Add to localized dictionary
 (5) Add to StatsVC
 (6) Add to analytics.php */

#define KEY_LOV @"LOV"
#define KEY_EDU @"EDU"
#define KEY_FOO @"FOO"
#define KEY_CLO @"CLO"
#define KEY_SAR @"SAR"
#define KEY_SHO @"SHO"
#define KEY_SAR @"SAR"
#define KEY_SHO @"SHO"
#define KEY_ACC @"ACC"
#define KEY_STA @"STA"
#define KEY_PEN @"PEN"
#define KEY_HYG @"HYG"
#define KEY_BOO @"BOO"
#define KEY_FUR @"FUR"
#define KEY_ELE @"ELE"
#define KEY_SOF @"SOF"
#define KEY_COM @"COM"
#define KEY_SOC @"SOC"
#define KEY_TRA @"TRA"
#define KEY_ENT @"ENT"
#define KEY_HOU @"HOU"
#define KEY_AUT @"AUT"
#define KEY_LEG @"LEG"
#define KEY_TAX @"TAX"
#define KEY_INS @"INS"
#define KEY_MIS @"MIS"
#define KEY_INV @"INV"

//#define ServerIP @"127.0.0.1"   // Local host
//#define ServerIP @"10.31.12.25"
#define ServerIP    [JNKeychain loadValueForKey:KEY_CACHED_IP]
#define ServerURL   [NSString stringWithFormat:@"http://%@:7777/groceryprivate", ServerIP]
#define ServerApiURL    [NSString stringWithFormat:@"%@/api/api.php", ServerURL]

//#define ServerURL @"http://fitdata.cn/server/grocery"                // Use AWS server
//#define ServerURL @"http://120.55.92.238/grocery"   // Aliyun Server

#define TYPE_LOV NSLocalizedString(@"TYPE_LOV", nil)
#define TYPE_EDU NSLocalizedString(@"TYPE_EDU", nil)
#define TYPE_FOO NSLocalizedString(@"TYPE_FOO", nil)
#define TYPE_CLO NSLocalizedString(@"TYPE_CLO", nil)
#define TYPE_SAR NSLocalizedString(@"TYPE_SAR", nil)
#define TYPE_ACC NSLocalizedString(@"TYPE_ACC", nil)
#define TYPE_SHO NSLocalizedString(@"TYPE_SHO", nil)
#define TYPE_STA NSLocalizedString(@"TYPE_STA", nil)
#define TYPE_PEN NSLocalizedString(@"TYPE_PEN", nil)
#define TYPE_HYG NSLocalizedString(@"TYPE_HYG", nil)
#define TYPE_BOO NSLocalizedString(@"TYPE_BOO", nil)
#define TYPE_FUR NSLocalizedString(@"TYPE_FUR", nil)
#define TYPE_ELE NSLocalizedString(@"TYPE_ELE", nil)
#define TYPE_SOF NSLocalizedString(@"TYPE_SOF", nil)
#define TYPE_COM NSLocalizedString(@"TYPE_COM", nil)
#define TYPE_SOC NSLocalizedString(@"TYPE_SOC", nil)
#define TYPE_TRA NSLocalizedString(@"TYPE_TRA", nil)
#define TYPE_ENT NSLocalizedString(@"TYPE_ENT", nil)
#define TYPE_HOU NSLocalizedString(@"TYPE_HOU", nil)
#define TYPE_AUT NSLocalizedString(@"TYPE_AUT", nil)
#define TYPE_LEG NSLocalizedString(@"TYPE_LEG", nil)
#define TYPE_TAX NSLocalizedString(@"TYPE_TAX", nil)
#define TYPE_INS NSLocalizedString(@"TYPE_INS", nil)
#define TYPE_MIS NSLocalizedString(@"TYPE_MIS", nil)
#define TYPE_INV NSLocalizedString(@"TYPE_INV", nil)

#define START_DATE NSLocalizedString(@"START_DATE", nil)
#define END_DATE NSLocalizedString(@"END_DATE", nil)
#define STATS NSLocalizedString(@"STATS", nil)

#define ITEM_CELL_TITLE NSLocalizedString(@"ITEM_CELL_TITLE", nil)
#define COUNT_CELL_TITLE NSLocalizedString(@"COUNT_CELL_TITLE", nil)
#define PRICE_CELL_TITLE NSLocalizedString(@"PRICE_CELL_TITLE", nil)
#define TYPE_CELL_TITLE NSLocalizedString(@"TYPE_CELL_TITLE", nil)
#define CURRENCY_CELL_TITLE NSLocalizedString(@"CURRENCY_CELL_TITLE", nil)
#define PRICECNY_CELL_TITLE NSLocalizedString(@"PRICECNY_CELL_TITLE", nil)
#define PRICE_CELL_DATE NSLocalizedString(@"PRICE_CELL_DATE", nil)
#define TOTAL_CELL_TITLE NSLocalizedString(@"TOTAL_CELL_TITLE", nil)

#define ITEM_CELL_PLACEHOLDER NSLocalizedString(@"ITEM_CELL_PLACEHOLDER", nil)
#define COUNT_CELL_PLACEHOLDER NSLocalizedString(@"COUNT_CELL_PLACEHOLDER", nil)
#define PRICE_CELL_PLACEHOLDER NSLocalizedString(@"PRICE_CELL_PLACEHOLDER", nil)

#define INVALID_NUM_ALERT_TITLE NSLocalizedString(@"INVALID_NUM_ALERT_TITLE", nil)
#define INVALID_NUM_ALERT_MESSAGE NSLocalizedString(@"INVALID_NUM_ALERT_MESSAGE", nil)
#define ALERT_DISMISS NSLocalizedString(@"ALERT_DISMISS", nil)

#define USER_ID_CELL_TITLE NSLocalizedString(@"USER_ID_CELL_TITLE", nil)
#define CHANGE_PASSWORD_CELL_TITLE NSLocalizedString(@"CHANGE_PASSWORD_CELL_TITLE", nil)
#define LOGOUT_CELL_TITLE NSLocalizedString(@"LOGOUT_CELL_TITLE", nil)
#define LOGIN_CELL_TITLE NSLocalizedString(@"LOGIN_CELL_TITLE", nil)
#define SIGNUP_CELL_TITLE NSLocalizedString(@"SIGNUP_CELL_TITLE", nil)
#define PASSWORD_CELL_TITLE NSLocalizedString(@"PASSWORD_CELL_TITLE", nil)
#define NO_ACCOUNT NSLocalizedString(@"NO_ACCOUNT", nil)

#define OLD_PASSWORD_PLACEHOLDER NSLocalizedString(@"OLD_PASSWORD_PLACEHOLDER", nil)
#define NEW_PASSWORD_PLACEHOLDER NSLocalizedString(@"NEW_PASSWORD_PLACEHOLDER", nil)

#define NO_ITEM_NAME_ALERT_TITLE NSLocalizedString(@"NO_ITEM_NAME_ALERT_TITLE", nil)
#define NO_ITEM_NAME_ALERT_MESSAGE NSLocalizedString(@"NO_ITEM_NAME_ALERT_MESSAGE", nil)
#define NO_ITEM_NAME_ALERT_ACT NSLocalizedString(@"NO_ITEM_NAME_ALERT_ACT", nil)


#define TO_ADD_ITEM_SEGUE           @"toAddItem"
#define TO_CHECK_DAY_SEUGUE         @"toCheckDay"
#define TO_CHECK_MONTH_SEUGUE       @"toCheckMonth"
#define TO_UPDATE_ITEM_SEGUE        @"toUpdateItem"

#define UNWIND_TO_GROCERY_LIST      @"unwindtoGroceryList"

#define LOCALIZED_NUM_ITEMS_TIMES_PRICE_EQUAL_NET NSLocalizedString(@"NUM_ITEMS_TIMES_PRICE_EQUAL_NET", nil)
#define LOCALIZED_CASH_SHORT NSLocalizedString(@"CASH_SHORT", nil)

#pragma mark - Alert
#define ALERT NSLocalizedString(@"ALERT", nil)

#define DISMISS_ALERT_ACTION_DEFAULT NSLocalizedString(@"DISMISS_ALERT_ACTION_DEFAULT", nil)

#define MISSING_INPUT NSLocalizedString(@"MISSING_INPUT", nil)

#define ALERT_LOGIN_FAILED_SUBTEXT_INCORRECT_CREDENTIALS NSLocalizedString(@"ALERT_LOGIN_FAILED_SUBTEXT_INCORRECT_CREDENTIALS", nil)
#define ALERT_LOGIN_FAILED_SUBTEXT_ACCOUNT_DOES_NOT_EXIST NSLocalizedString(@"ALERT_LOGIN_FAILED_SUBTEXT_ACCOUNT_DOES_NOT_EXIST", nil)
#define ALERT_LOGIN_FAILED_SUBTEXT_NO_ACCOUNT_INPUT NSLocalizedString(@"ALERT_LOGIN_FAILED_SUBTEXT_NO_ACCOUNT_INPUT", nil)
#define ALERT_LOGIN_FAILED_SUBTEXT_NO_PASSWORD_INPUT NSLocalizedString(@"ALERT_LOGIN_FAILED_SUBTEXT_NO_PASSWORD_INPUT", nil)

#define REGISTER_FAILED_EMPTY_USER_ID NSLocalizedString(@"REGISTER_FAILED_EMPTY_USER_ID", nil)
#define REGISTER_FAILED_INVALID_USER_ID NSLocalizedString(@"REGISTER_FAILED_INVALID_USER_ID", nil)
#define REGISTER_FAILED_ID_LENGTH_INVALID NSLocalizedString(@"REGISTER_FAILED_ID_LENGTH_INVALID", nil)

#define REGISTER_FAILED_EMPTY_PASSWORD NSLocalizedString(@"REGISTER_FAILED_EMPTY_PASSWORD", nil)
#define REGISTER_FAILED_INVALID_PASSWORD NSLocalizedString(@"REGISTER_FAILED_INVALID_PASSWORD", nil)
#define REGISTER_FAILED_PASSWORD_LENGTH_INVALID NSLocalizedString(@"REGISTER_FAILED_PASSWORD_LENGTH_INVALID", nil)
#define REGISTER_FAILED_PASSWORD_MISMATCH NSLocalizedString(@"REGISTER_FAILED_PASSWORD_MISMATCH", nil)
#define REGISTER_FAILED_USER_EXISTS NSLocalizedString(@"REGISTER_FAILED_USER_EXISTS", nil)

#define CONNECTION_FAILED NSLocalizedString(@"CONNECTION_FAILED", nil)
#define CONNECTION_FAILED_NO_INTERNET NSLocalizedString(@"CONNECTION_FAILED_NO_INTERNET", nil)
#endif /* Macros_h */
