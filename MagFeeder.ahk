; Feeding 1-9, 12, 15, or 27 mags is the safest
;   Others are still considered safe but the above have their own image sets
;   There is a chance for error when feeding mags that don't have their own image sets.
;       when a mag isn't 1-4 or the last 4 mags 
;           due to middle mags using a generic center image to VerifyScreen()
;
;
; Sometimes the charater/inventory will desync from Ephinea's server.  Noticeable if you are logged off before your set time.
;   always double check that the levels are correct when resuming a feed
;
;
; All timers/A_tickcount can become unreliable on a very slow machine
;   PSO's timings are strictly related to it's frame rate?
;   to avoid it I COULD get the time from the machine and do the math from that for my timers?
;       alternatively I could try changing SetBatchLines https://www.autohotkey.com/docs/commands/SetBatchLines.html
;       CHANGING SetBatchLines -1 seems to lessen the issues
;
;

#Warn
#IfWinActive Ephinea: Phantasy Star Online Blue Burst
SendMode Event        ; REQUIRED!!!! PSOBB won't accept the deemed superior  
SetKeyDelay, 150, 70   ; SetKeyDelay, 150, 70  1st parameter is delay between keys 2nd is how long the button is pressed


; the GUI that is opened with Ctrl + K
Gui, Add, Text,, Key Delay:
Gui, Add, Text,, Key Duration:
Gui, Add, Edit, vKeyDelay ym, %A_KeyDelay%   ; The ym option starts a new column of controls.
Gui, Add, Edit, vKeyDuration, %A_KeyDuration%
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.


; Global Mag Table Variables
global g_magFeedTbl1, g_magFeedTbl2, g_magFeedTbl3, g_magFeedTbl4, g_magFeedTbl5
global g_magFeedTbl6, g_magFeedTbl7, g_magFeedTbl8, g_magFeedTbl9, g_magFeedTbl10   
global g_magFeedTbl11, g_magFeedTbl12, g_magFeedTbl13, g_magFeedTbl14, g_magFeedTbl15
global g_magFeedTbl16 , g_magFeedTbl17, g_magFeedTbl18, g_magFeedTbl19, g_magFeedTbl20
global g_magFeedTbl21, g_magFeedTbl22, g_magFeedTbl23, g_magFeedTbl24, g_magFeedTbl25
global g_magFeedTbl26, g_magFeedTbl27
global g_magArray, g_posArray, g_charCast, g_magTimers

global g_macroAttempt := 0 ; Consecutive count of the current macro's attempt 

global g_failedSearches := [] ; stores failed image searches Ctrl + I to view them in a MsgBox

global pauseAfterCycle := false   ; set to true with the MsgBox from Ctrl + E , Ctrl + P defaults it back to false

global g_lastItemFed := { magIdx: 0, itemImage: "", itemCountImage: "" } 

; Used to decide how many items to purchase in shouldItBuy9(magIdx) 
; Also to decide ImageSearch in FeedMagMacro()
global itemsInventory := []


global g_debugStorage := []
global g_macroTracker := []

; HELPFUL MACRO INSTRUCTIONS.
^r::reload  ; Ctrl + R - Restarts script.

^p::  ; Ctrl + P - Pauses script.
    Pause   
    pauseAfterCycle := false
    return

^e:: ; Ctrl + E - Pauses script after the current feed cycle finishes.
    MsgBox, 4, "Mag Feeder", "Pause after current feed cycle is finished?"
    IfMsgBox Yes
        pauseAfterCycle := true
    IfMsgBox No
        pauseAfterCycle := false
    return

^i:: ; Ctrl + I - display failed ImageSearch's
    displayFailedSearches := ""
    Loop % g_failedSearches.Length() {
        displayFailedSearches := displayFailedSearches "`n"
        displayFailedSearches := displayFailedSearches g_failedSearches[ ( g_failedSearches.Length() + 1 ) - A_Index ]
    } 
    MsgBox The following images failed to verify on the screen at some point, displaying from newest to oldest. %displayFailedSearches%
    return


^t:: ; Ctrl + T - test hotkey
    
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, MagImagesBloodyHUD\Capture.PNG
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search.
        else if (ErrorLevel = 1)
            MsgBox Icon could not be found on the screen.
        else
            MsgBox The icon was found at %FoundX%x%FoundY%.
    
    return
; Default HUD should not be used. 
;   It has too much transparency to be effective.
; Bloody HUD should help for deciding which mag is being fed but it's about the same for shop menu, but buy can be located.
; Golden HUD good at deciding what mag is selected but bad in the shop


^c:: ; Ctrl + C - Used to display the previous cycles
    displayVariables := ""
    Loop % g_macroTracker.Length() {
        displayVariables := displayVariables "`n"
        displayVariables := displayVariables g_macroTracker[ ( g_macroTracker.Length() + 1 ) - A_Index ]
    } 
    MsgBox Previous actions from newest to oldest, %displayVariables%
    return


^d:: ; Ctrl + D - Used to display variables while debugging/troubleshooting

    displayVariables := ""
    Loop % g_debugStorage.Length() {
        displayVariables := displayVariables "`n"
        displayVariables := displayVariables g_debugStorage[ ( g_debugStorage.Length() + 1 ) - A_Index ]
    } 
    MsgBox Newest to oldest from g_debugStorage, %displayVariables%
    return



^q:: ; Ctrl + Q - Display itemsInventory 
    displayInventory := ""
    Loop % itemsInventory.Length() {
        displayInventory := displayInventory "`n"
        displayInventory := displayInventory itemsInventory[ A_Index ]
    } 
    MsgBox  itemsInventory, starting at index 1 %displayInventory%
    return


^k:: ; Ctrl + K - displays a GUI that allows user to SetKeyDelay, DOES NOT CURRENTLY WORK 
;           I believe the variables will need to be made global and checked for change at the beginning of each macro function 
    Gui, Show,, Key input settings.
    return  ; End of auto-execute section. The script is idle until the user does something.

    GuiClose:
    ButtonOK:
    Gui, Submit  ; Save the input from the user to each control's associated variable.
    KeyDelay := KeyDelay + 0
    KeyDuration := KeyDuration + 0
    SetKeyDelay, %KeyDelay%, %KeyDuration%
    MsgBox, Key delay is set to %A_KeyDelay% and duration is %A_KeyDuration%
    return




; ----------------------------------------------------------
;    Primary Control Function for User of this script.
;       Author: RoySilverblade, 2018
;
;       Additions by: Beev, 2020
;       Refactored for V1 (current) AutoHotKey
;       Added some feed optimizations
;       , additional functionality/logic
;       and ImageSearch checks to guarantee it's feeding
;       correctly. ( lag won't botch feeds now!)
; ----------------------------------------------------------
    

^j::    ; Ctrl + J - Begins the mag feeding macro.
    { 
    ; ------------------------------------------------------
    ;    Perform Edits Here!!!!
    ;   These tables control feed patterns for each mag,
    ;   each table corresponds to one mag you intend to
    ;   level.
    ;
    ;   It's fastest to feed mags in sets of 3
    ;
    ; ------------------------------------------------------           

    ; If feeding as a Cast character g_charCast should := "cast" OR IF NOT A CAST := ""
    g_charCast := ""
    ; SHOULD ADD A YES/NO MsgBox to confirm which character type is feeding

    ; HuCast cheapKamas
	g_magFeedTbl1 := [ "Dimate", 1 ]
    g_magFeedTbl2 := [ "Dimate", 1 ]
    g_magFeedTbl3 := [ "Dimate", 1 ]
    g_magFeedTbl4 := [ "Dimate", 1 ] 
    g_magFeedTbl5 := [ "Dimate", 1 ]
    g_magFeedTbl6 := [ "Dimate", 1 ]
    g_magFeedTbl7 := [ "Dimate", 1 ]
    g_magFeedTbl8 := [ "Dimate", 1 ]
    g_magFeedTbl9 := [ "Dimate", 1 ] 
    g_magFeedTbl10 := [ "Dimate", 1 ]  
    g_magFeedTbl11 := [ "Dimate", 1 ]  
    g_magFeedTbl12 := [ "Dimate", 1 ] 
    g_magFeedTbl13 := [ "Dimate", 1 ]  
    g_magFeedTbl14 := [ "Dimate", 1 ]  
    g_magFeedTbl15 := [ "Dimate", 1 ]
    g_magFeedTbl16 := [ "Dimate", 1 ]   
    g_magFeedTbl17 := [ "Dimate", 1 ]
    g_magFeedTbl18 := [ "Dimate", 1 ]  
    g_magFeedTbl19 := [ "Dimate", 1 ]  
    g_magFeedTbl20 := [ "Dimate", 1 ]
    g_magFeedTbl21 := [ "Dimate", 1 ]  
    g_magFeedTbl22 := [ "Dimate", 1 ]  
    g_magFeedTbl23 := [ "Dimate", 1 ]
    g_magFeedTbl24 := [ "Dimate", 1 ] 
    g_magFeedTbl25 := [ "Dimate", 1 ]
    g_magFeedTbl26 := [ "Dimate", 1 ]
    g_magFeedTbl27 := [ "Dimate", 1 ]
    ; ------------------------------------------------------
    ;    Perform Edits Here!!!!
    ;   This table must contain all of the tables created
    ;   above and is the main table used throughout this
    ;   routine. 
    ; ------------------------------------------------------

    g_magArray 
    := [ g_magFeedTbl1, g_magFeedTbl2, g_magFeedTbl3
        , g_magFeedTbl4, g_magFeedTbl5, g_magFeedTbl6
        , g_magFeedTbl7, g_magFeedTbl8, g_magFeedTbl9
        , g_magFeedTbl10, g_magFeedTbl11, g_magFeedTbl12
        , g_magFeedTbl13, g_magFeedTbl14, g_magFeedTbl15
        , g_magFeedTbl16, g_magFeedTbl17, g_magFeedTbl18
        , g_magFeedTbl19, g_magFeedTbl20, g_magFeedTbl21
        , g_magFeedTbl22, g_magFeedTbl23, g_magFeedTbl24
        , g_magFeedTbl25, g_magFeedTbl26, g_magFeedTbl27 ] 

    


    ; SHOULD ADD A MsgBox that verifies how many mags are being fed, probably combine it with the Cast MsgBox

    

    ; 1 second sleep after user initiates feed.
    Sleep, 1000
    ; Begin feeding the mags designated by the g_magArray table's list of feed tables
    FeedMags( )
    Exit
    }   
    
        
; ----------------------------------------------------------
;
;  Function
;      Feed Mags - Feed mags based on provided feed list.
;
; ----------------------------------------------------------

FeedMags( )
    {   
    ; Do inital validation and prep
    if ( GetNumMags() == 0 or GetNumMags() > 27 )
        {
        MsgBox "Error - Mag Arrays aren't initialized properly."
        }

    ; Create a position array of equal length to the mag array
    g_posArray := []
    ; Create an array of tick counts, used to track time in between feeds
    g_magTimers := []
    Loop % GetNumMags(){
        g_posArray.Push( 1 )
        g_magTimers.Push( A_TickCount )
    }



    Loop
        {

        
        ; Reset to the first mag
        magIdx := 1     
        anyMagFed := False

        ; Buy items for the first mag's feed
        cnt := BuyFeedAmount( magIdx )

        Loop
            {
            
            ; Sleep until 210 seconds have passed since the mags last feed was finished
            ;       Timers / A_TickCount can be unstable on slow machines
            if ( ( A_TickCount - g_magTimers[ magIdx ] ) < 210000 )
                {
                Sleep, 210000 - ( A_TickCount - g_magTimers[ magIdx ] )
                }

            ; Some items were purchased to be fed to this mag
            if ( cnt > 0 )   
                {
                FeedMagMacro( magIdx, cnt )
                ; I used to set the timers before FeedMagMacro, now they are set afterwards for improved reliability.  It may add time to the total script runtime when compared though.
                g_magTimers[ magIdx ] := A_TickCount
                anyMagFed := True
                }
                
            ; Move to next mag, if one exists or go back to parent loop.
            if ( ++magIdx > GetNumMags() )   
                {
                if ( pauseAfterCycle )   
                    {
                    Pause
                    }
                break
                }

            ; Buy next set of items for next mag
            cnt := BuyFeedAmount( magIdx )   
            
            }
        } Until anyMagFed = False   ; If no mags were fed during the last iteration, we have completed the feed
        
    MsgBox "Mag(s) Feed Script Finished!"
    }
  
        
; ----------------------------------------------------------
;
;  Function
;      Buy Feed Amount - Buy items for a single mag feed.
;          Or for the next 3, if the current and following 2 mags are all being fed the same item *3 (9 total)
;
;    Arguments
;         magIdx - Mag to purchase items for.
;
; ----------------------------------------------------------

BuyFeedAmount( magIdx )
    { 
    ; Initialize number of feeds executed and max number of feeds
    curCnt := 0
    feedsLeft := 3 

    ; Continue item purchases until we've reach the max feed or the mag is complete
    while ( !MagComplete( magIdx ) and feedsLeft > 0 )
        {  
        ; Incase it wants to buy, item1 item2 item1.  This would go to stack item1 in the first position, offsetting the feed order.
        ; if there is already two items in the inventory and the next item to buy is = first in inventory 
        if ( itemsInventory[3] and itemsInventory[1] == GetNextFeedType( magIdx ) )
        {
            ; exit the loop
            Break
        }


        ; There are more feeds requested then are available, buy only for feeds we have available
        if ( GetNextFeedCnt( magIdx ) >= feedsLeft )
            {
            ; if itemsInventory[2] does not exist and feedsLeft == 3
            if ( !itemsInventory[2] and feedsLeft == 3 )
                {
                shouldItBuy9( magIdx ) ? BuyConsumablesMacro( GetNextFeedType( magIdx ), 9 ) : BuyConsumablesMacro( GetNextFeedType( magIdx ), feedsLeft )
                }
            ; if this wasn't here it would buy more items even when it already has them in inventory
            else if ( feedsLeft < 3 )
                {
                BuyConsumablesMacro( GetNextFeedType( magIdx ), feedsLeft )
                } 
            RegisterFeeds( magIdx, feedsLeft )
            curCnt += feedsLeft
            feedsLeft := 0
            }
        ; There are less feeds requested then are available, buy all requested
        else   
            {
            cnt := GetNextFeedCnt( magIdx )
            BuyConsumablesMacro( GetNextFeedType( magIdx ), cnt )
            RegisterFeeds( magIdx, cnt )
            curCnt += cnt
            feedsLeft -= cnt
            }
        }
        
    Return curCnt  ; Return number of feeds purchased for
    }
    
    
; ----------------------------------------------------------
;
;  Function
;      Mag Complete - Is this mag completely done being fed.
;
;    Arguments
;         magIdx - Mag to check feed table of.
;
; ----------------------------------------------------------

MagComplete( magIdx )
    {       
    if (g_posArray[magIdx] > g_magArray[magIdx].Length())
        {
        return True
        }
    else 
        {
        return False
        }
    }
    
        
; ----------------------------------------------------------
;
;  Function
;      Get Next Feed Type - Returns the next feed type.
;
;    Arguments
;         magIdx - Mag to check feed table of.
;
; ----------------------------------------------------------

GetNextFeedType( magIdx )
    {           
    Return g_magArray[magIdx][g_posArray[magIdx]]
    }
    
    
; ----------------------------------------------------------
;
;  Function
;      Get Next Feed Count - Returns the next feed count.   
;
;    Arguments
;         magIdx - Mag to check feed table of.
; ----------------------------------------------------------

GetNextFeedCnt( magIdx )
    {           
    Return g_magArray[magIdx][g_posArray[magIdx]+1]
    }
    
    
; ----------------------------------------------------------
;
;  Function
;      Get Number Mags - Returns the # of mags being fed.
;
; ----------------------------------------------------------

GetNumMags( )
    {
    Return g_magArray.Length()
    }
    
    
; ----------------------------------------------------------
;
;  Function
;      Register Feeds - Update Feed and Position table.
;
;    Arguments
;         magIdx - Mag to update feed table of.
;         cnt    - Number of items fed.       
;
; ----------------------------------------------------------
 

RegisterFeeds( magIdx, cnt )
    {       
    g_magArray[magIdx][g_posArray[magIdx]+1] -= cnt
    
    ; If we've completed all the feeds of this item, update position to next item
    if ( g_magArray[magIdx][g_posArray[magIdx]+1] <= 0 )
        {
        g_posArray[magIdx] += 2
        }
    }
    
    
; ----------------------------------------------------------
;
;    Function
;        Feed Mag Macro - Feed an item to mag
;
;    Arguments
;         magNum - Mag to feed.
;       cnt    - Number of times to feed it.
;
; ----------------------------------------------------------


FeedMagMacro( magNum, cnt )
    {
    ; Validate count value
    if ( cnt <= 0 || cnt > 3 )
        {
        MsgBox "Instructed to feed mag an invalid number of times"
        Exit
        }

    ++g_macroAttempt 
    if ( g_macroAttempt > 10 )
        {
        topItem := itemsInventory[1]
        MsgBox Feed mag macro has failed 10 consecutive attempts at feeding mag %magNum% %topItem% x%cnt% !
        }


    ; Feed the mag based on the count
    loop % cnt {
        
        Send {F4}        ; Open Mag Menu
        ; Searches screen for mag menu icon
        if ( !VerifyScreen( "MagImagesBloodyHUD\MagMenu.PNG" ) )
            {
            Send {Backspace 4} ; Backspace x4 incase it's still in a shop menu
            FeedMagMacro( magNum, cnt - ( A_Index - 1 ) )
            return
            }
        if ( magNum <= ( Round( g_magArray.Length() / 2 ) ) )
            {
            Loop %  magNum - 1  {
                Send {Down}  ; select 'n'th mag
                }
            }
        else 
            {
            Loop % g_magArray.Length() - magNum + 1{
                Send {Up}   ; select 'n'th mag
                }
            }
        
        ; verify correct mag is highlighted
        if ( !VerifyScreen( DecideMagImage( magNum ) ) )
            {
            RetryMagFeed( magNum, cnt - ( A_Index - 1 ) )
            return
            }
        Send {Enter}        ; select Mag
        
        ; verify Give Items option is on screen
        if ( !VerifyScreen( "MagImagesBloodyHUD\Give Items.PNG" ) )
            {
            RetryMagFeed( magNum, cnt - ( A_Index - 1 ) )
            return
            }
        Send {Enter}        ; select Give Items

        ; Cast character types require different images for some items and item counts in the mag menu
        magItemImage := "MagImagesBloodyHUD\" itemsInventory[1] ".PNG"
        itemCountImage := "MagImagesBloodyHUD\x" itemsInventory[2] ".PNG"
        if ( itemsInventory[1] == "Monofluid" or itemsInventory[1] == "Difluid" or itemsInventory[1] == "Trifluid" or itemsInventory[1] == "Antiparalysis" or itemsInventory[1] == "Antidote" )
            {
            if ( g_charCast == "cast" ) 
                {
                magItemImage := "MagImagesBloodyHUD\" g_charCast itemsInventory[1] ".PNG"
                itemCountImage := "MagImagesBloodyHUD\" g_charCast "x" itemsInventory[2] ".PNG"
                }
            }
        ; verify the correct item to feed is on screen and in the first to feed position.
        ; Also check that the top item in the feed list is displaying the correct amount.
        if ( !VerifyScreen( magItemImage ) or !VerifyScreen( itemCountImage ) )
            {
            ; if the next mag to feed is feeding the current item x1 next and the current feed is x1
            if ( cnt == 1 and GetNextFeedCnt( NextFeedableMag( magNum + 1 ) ) == 1 and GetNextFeedType( NextFeedableMag( magNum + 1 ) ) == itemsInventory[1] )
                {
                ; I SHOULD CONSIDER REPLACING THE BELOW WITH A PAUSE AND DeductInventory() ???
                ; I should not assume that it should be retrying the current mag or the last mag.  WITH THE INFO PROVIDED
                ; IT SHOULD BE A VERY RARE OCCURENCE TO FIND THE CODE EXECUTING HERE
                g_debugStorage.Push( "Assuming it should retry current mag.  Near line 600." )
                ; assumes a mishap in the above image searching and retries current feed
                RetryMagFeed( magNum, 1 )
                return
                }
            ; Incase the previous select Feed Item did not register, retry feeding that item
            else if ( g_lastItemFed.magIdx > 0 and VerifyScreen( g_lastItemFed.itemImage ) and VerifyScreen( g_lastItemFed.itemCountImage ) )
                {
                g_macroAttempt := 0
                Send {F4} ; exit Mag Menu
                RedoLastFeed()  ; retries the last mag/item fed
                g_debugStorage.Push( "Then it should resume feeding mag " magNum ", " cnt - ( A_Index - 1 ) " items" )
                }

            RetryMagFeed( magNum, cnt - ( A_Index - 1 ) )
            return
            }
        Send {Enter}        ; select Feed Item


        ; reduces the count stored in the itemsInventory array
        DeductInventory()

        ; store the variables needed to retry the item that was just given, incase the item was not actually fed to the mag
        g_lastItemFed := { magIdx: magNum, itemImage: magItemImage, itemCountImage: itemCountImage } 

        Send {F4}         ; exit Mag Menu
        g_macroAttempt := 0 
        g_macroTracker.Push( "mag " magNum " was fed a " g_lastItemFed.itemImage )
        } ; end of feed loop
    } ; end of FeedMagMacro
    

; ----------------------------------------------------------
;
;    Function
;        Buy Consumables Macro - Purchases items from shop.
;
;    Arguments
;         type - requested item, must be in quotes.
;        num  - number to be selected.
;
; ----------------------------------------------------------

BuyConsumablesMacro( type, num )
    {   
    ++g_macroAttempt 
    if ( g_macroAttempt > 10 )
        {
        MsgBox Buy consumables macro has failed 10 consecutive attempts!
        }
    ; Checks for image that's only available when out of the store or in an in-game menu
    if ( !VerifyScreen( "BloodyHUDPiece.PNG" ) )
        {
        RetryShop( type,num )
        return
        }


    Send {Enter}          ; talk to shop
    ; Buy.PNG should be displayed on screen.
    if ( !VerifyScreen( "ShopImagesBloodyHUD\Buy.PNG" ) )
        {
        RetryShop( type,num )
        return
        }

    Send {Enter}          ; select buy
    
    SelectItem( type )      ; select item from store
    itemImage := "ShopImagesBloodyHUD\" type ".PNG"
    if ( g_charCast == "cast" )
        {
        if ( type == "Monofluid" or type == "Difluid" or type == "Trifluid" or type == "Antidote" or type == "Antiparalysis" )
            {
            itemImage := "ShopImagesBloodyHUD\cast" type ".PNG"
            }
        }

    ; Make sure the correct item is highlighted on screen.
    if ( !VerifyScreen( itemImage ) )
        {
        RetryShop( type,num )
        return
        }

    ; Item Quantity0.PNG should be displayed on screen.  Should only be sent to buy something when inventory of that item is 0
    if ( !VerifyScreen( "ShopImagesBloodyHUD\Item Quantity0.PNG" ) )
        {
        ; if the last feed failed to actually feed the last item and the last item = type (current item to buy)
        ; this will not catch an item in inventory that is different than type (current item to buy)
        if ( VerifyScreen( "ShopImagesBloodyHUD\Item Quantity1.PNG" ) )
            {
            Send {Backspace 3} ; Backspace x3, exit out of shop
            g_macroAttempt := 0

            ; Feed the last of this item to the last mag fed
            RedoLastFeed()
            g_debugStorage.Push( "Then it should resume buying " type " x" num )
            }
        RetryShop( type,num )
        return
        }

    Send {Enter}          ; begins item quantity selector
    SelectQuantity( num )   ; select quantity of item 
    
    ; xAmount.PNG should be displayed on screen.
    if ( !VerifyScreen( "ShopImagesBloodyHUD\x" num ".PNG" ) )
        {
        RetryShop( type,num )
        return
        }
      
    Send {Enter}          ; brings up buy menu

    ; Looks similar to Buy.PNG but is different
     if ( !VerifyScreen( "ShopImagesBloodyHUD\BuyItems.PNG" ) )
        {
        RetryShop( type,num )
        return
        }
    Send {Enter}          ; purchases item(s)

    ; Currently the script should only be buying an item when it's at 0
    ; So variable num will work here 
    ; VERIFIES THE CORRECT AMOUNT WAS PURCHASED
    if ( !VerifyScreen( "ShopImagesBloodyHUD\Item Quantity" num ".PNG" ) )
        {
        ; if it didn't purchase the items
        if ( VerifyScreen( "ShopImagesBloodyHUD\Item Quantity0.PNG" ) )
            {
            RetryShop( type,num )
            return
            }
        else 
            {
            MsgBox Invalid items purchased.  Script paused, empty inventory and unpause.
            Pause
            RetryShop( type,num )
            return
            }
        }
    
    ; Push the purchased items into an array to decide when to call shouldItBuy9() and to find the correct images for VerifyScreen() in FeedMagMacro()
    itemsInventory.Push( type, num )


    Send {Backspace 3} ; Backspace x3, exit out of shop

    ; Checks for image that's only available when out of the store or in an in-game menu
    if ( !VerifyScreen( "BloodyHUDPiece.PNG" ) )
        {
        Send {Backspace 4} ; Backspace x4, exit out of shop menu, 1 extra backspace incase it's further in the menu
        }
    g_macroAttempt := 0
    g_macroTracker.Push( num " " type " purchased" )
    }
    
    
; ----------------------------------------------------------
;
;     Function
;        Select Item - Navigates to requested item.
;
;    Arguments
;         type - Requested item, must be in quotes.
;
; ----------------------------------------------------------

SelectItem( type )
    {   
    
    ; Determine which item is being requested, and navigate the menu to that item
    if ( type = "Monomate" || type = "mm" )
        {
        ; Intentionally left empty
        }
    else if ( type = "Dimate" || type = "dm" )
        {
        Send {Down}      ; highlights dimate
        }
    else if ( type = "Trimate" || type = "tm" )
        {   
        Send {Down 2}       ; highlights trimate
        }
    else if ( type = "Monofluid" || type = "mf" )
        {
        Send {Down 3}      ; highlights monofluid
        }
    else if ( type = "Difluid" || type = "df" )
        {
        Send {Down 4}      ; highlights difluid
        }
    else if ( type = "Trifluid" || type = "tf" )
        {
        Send {Down 5}      ; highlights trifluid
        }
    else if ( type = "Sol Atomizer" || type = "sol" )
        {
        Send {Up 7}         ; highlights sol atomizer
        }
    else if ( type = "Moon Atomizer" || type = "moon" )
        {
        Send {Up 6}         ; highlights moon atomizer
        }
    else if ( type = "Star Atomizer" || type = "star" )
        {
        Send {Up 5}         ; highlights star atomizer
        }
    else if ( type = "Antidote" || type = "ad" )
        {
        Send {Up 4}         ; highlights antidote
        }
    else if ( type = "Antiparalysis" || type = "ap" )
        {
        Send {Up 3}         ; highlights antiparalysis
        }
    else
        {
        MsgBox "Error - Invalid item type to buy"
        Exit
        }
        
    }
    
    
; ----------------------------------------------------------
;
;    Function
;        Select Quantity - Navigates to requested quantity.
;   
;    Arguments
;         quantity - Number to be selected.
;
; ----------------------------------------------------------
    
SelectQuantity( quantity )
    {
    ; Validate quantity supplied
    if ( quantity <= 0 || quantity > 10 )
        {
        MsgBox "Error - Invalid count requested for purchase"
        Exit
        }
        
    ; High quantity requested, decrement from 10
    else if ( quantity > 5 )
        {
        Send {Down}      ; move to 10 quantity.
        Loop % 10 - quantity {
            Send {Down}  ; decrement quantity by 1.
            }
        }
        
    ; Low quantity requested, increment from 1
    else
        {
        Loop % quantity - 1 {
            Send {Up}     ; increment quantity by 1.
            }
        }       
    }
    

; ----------------------------------------------------------
;
;   Function
;      Should It Buy 9 - Will return True, if the current mag and next two mags are all being fed the same item *3. 
;
;    Arguments
;         magIdx - Mag to check feed table of.
;
; ----------------------------------------------------------

shouldItBuy9(magIdx)
    {
    nextTwoMags := []
    nextTwoMags[1] := NextFeedableMag( magIdx + 1 )
    nextTwoMags[2] := NextFeedableMag( nextTwoMags[1] + 1 )

    nextThreeSameFeed := False

    ; Incase the current mag is the only mag to feed
    if ( magIdx == nextTwoMags[1] and nextTwoMags[1] == nextTwoMags[2] )
        {
        if ( GetNextFeedCnt( magIdx ) >= 9 )
            {
            nextThreeSameFeed := True
            }
        }
    ; Incase there are only 2 mags left to feed
    else if (magIdx == nextTwoMags[2])
        {
        if ( GetNextFeedType( magIdx ) == GetNextFeedType( nextTwoMags[2] ) )
            {
            if ( GetNextFeedCnt( magIdx ) >= 6 and GetNextFeedCnt( nextTwoMags[1] ) >= 3 )
                {
                nextThreeSameFeed := True
                }
            }
        }
    ; There is 3 different mags to feed
    else if ( GetNextFeedType( magIdx ) == GetNextFeedType( nextTwoMags[1] ) and GetNextFeedType( nextTwoMags[1] ) == GetNextFeedType( nextTwoMags[2] ) )
        {
        if ( GetNextFeedCnt( nextTwoMags[1] ) >= 3 and GetNextFeedCnt( nextTwoMags[2]) >= 3 )
            {
            nextThreeSameFeed := True
            }
        }
    
    ; itemsInventory[GetNextFeedType( magIdx )] is == 0 when shouldItBuy9() is called 
    if ( nextThreeSameFeed )
        {
        ; itemsInventory[GetNextFeedType( magIdx )] := 9 ; this is not relevant anymore, as all items are pushed into itemsInventory when purchased 
        return true          
        }
    else return false
    }


; ----------------------------------------------------------
;
;  Function
;      Next Feedable Mag - will return the next mag to feed.
;
; ----------------------------------------------------------

NextFeedableMag(magIdx)
    {
    ; if mag is complete, find the next mag that's feedable 
    if ( MagComplete( magIdx ) or magIdx > GetNumMags() )
        {
        Loop % GetNumMags() - 1 {
            if ( magIdx + A_Index  <= GetNumMags() and MagComplete( magIdx + A_Index ) === False )
                {
                return magIdx + A_Index
                }
            else if ( MagComplete( ( magIdx + A_Index ) - GetNumMags() ) === False )
                {
                return ( magIdx + A_Index ) - GetNumMags()
                }
            }
        }
    else 
        {
        return magIdx
        }
    }


; ----------------------------------------------------------
;
;  Function
;      Verify Screen - returns true when images can be found.
;
;  Arguments
;      imagePath - string containing the file path of the image.
; ----------------------------------------------------------

VerifyScreen( filePath )
    {
    imageFound := false
    searchTimer := A_TickCount
    ; while imageFound == false, loop for up to 3 seconds
    while ( !imageFound and A_TickCount - searchTimer < 3000 )
        {
        ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, %filePath%
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search for %filePath%
        else if (ErrorLevel = 1)
            imageFound := false
        else
            imageFound := true
        }

    ; if the image could not be found in the while loop
    if ( !imageFound )
        {
        g_failedSearches.Push( filePath ) 
        }
    
    return imageFound
    }



; ----------------------------------------------------------
;
;  Function
;      Decide Mag Image - decides which mag image is needed while highlighting mag.
;
;  Arguments
;      magIdx - index of the current mag.
; ----------------------------------------------------------

 
DecideMagImage( magIdx )
    {
    if ( GetNumMags() <= 8 )
        {
        return "MagImagesBloodyHUD\Mag" magIdx ".PNG"
        }
    else if ( GetNumMags() == 12 or GetNumMags() == 15 or GetNumMags() == 27 )
        {
        return "MagImagesBloodyHUD\" magIdx "of" GetNumMags() ".PNG"
        }
    ; none of the below use the slider in the menu to decide position.
    else 
        {
        ; else 1-4 = Mag(1-4).PNG
        if ( magIdx <= 4 )
            {
            return "MagImagesBloodyHUD\Mag" magIdx ".PNG"
            }
        ; else if magIdx is one of the last 4, returns Mag-( 1 to 4 )
        else if ( GetNumMags() - magIdx <= 3 )
            {
            return "MagImagesBloodyHUD\Mag-" GetNumMags() - magIdx + 1 ".PNG"
            }
        ; else return generic center image
        else 
            {
            return "MagImagesBloodyHUD\GenericMag.PNG"
            }
        }
    }




RetryShop( type, num )
    {
    Send {Backspace 4} ; Backspace x4, exit out of shop menu, 1 extra backspace incase it's further in the menu
    BuyConsumablesMacro( type, num )
    ; If the script gets stuck in an out of money purchase situation 
    ; Or an inventory full situation THIS WILL NOT GET IT OUT OF THERE
    ; that would require  Send "{Enter}" before the Send "{Backspace 4}"
    ; IN THE CASE OF THE ABOVE IT SHOULD DISPLAY A MsgBox SAYING THAT IT HAS FAILED 10 CONSECUTIVE ATTEMPTS
    }




RetryMagFeed( magNum, cnt )
    {
    ; SHOULD VERIFY THAT IT'S IN THE MAG MENU BEFORE SENDING F4, ELSE SEND BACKSPACE x4
    if ( VerifyScreen( "MagImagesBloodyHUD\MagMenu.PNG" ) )
        {
        Send {F4}       ; exit Mag Menu
        }
    else 
        {
        Send {Backspace 4} ; Backspace x4, exit out of shop menu, 1 extra backspace incase it's further in the menu
        }

    g_debugStorage.Push( "retrying mag " magNum " x" cnt )
    ; restart FeedMagMacro,  cnt == how many left to feed this mag
    FeedMagMacro( magNum, cnt )
    }



DeductInventory()
    {
    itemsInventory[2] -= 1
    if ( itemsInventory[2] <= 0 )
        {
        itemsInventory.RemoveAt( 1, 2 )
        }
    }


RedoLastFeed()
    {
    ; Should return the item name from the itemImage string
    lastItem := SubStr( g_lastItemFed.itemImage,  20, -4 )
    if ( SubStr( lastItem, 1, 4 ) == "cast" )
        {
        lastItem := SubStr( g_lastItemFed.itemImage, 24, -4 )
        }

    g_debugStorage.Push( "Previous item detected, current inventory claims to be " itemsInventory[1] "x" itemsInventory[2]  )

    ; if itemsInventory does not contain this item as the first item, because the "feed item" key press didn't register.
    if ( itemsInventory[1] != lastItem )
        {
        ; inserts the items name and 1 to the beginning of the itemsInventory array
        itemsInventory.InsertAt( 1, lastItem, 1 )
        }
    ; else increment itemsInventory[2] by 1
    else 
        {
        ++itemsInventory[2]
        }
    ; g_lastItemFed needs to be defaulted before calling RetryMagFeed(), save the magIdx stored in it for use after
    lastMag := g_lastItemFed.magIdx

    g_debugStorage.Push( "This should be the correct current inventory " itemsInventory[1] "x" itemsInventory[2] )
    g_debugStorage.Push( "Attempting to feed mag " lastMag " " lastItem )
    

    g_lastItemFed := { magIdx: 0, itemImage: "", itemCountImage: "" }
    RetryMagFeed( lastMag, 1 )
    g_magTimers[ lastMag ] := A_TickCount
    }