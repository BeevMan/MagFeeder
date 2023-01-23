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


; Global Mag Table Variables
global g_magFeedTbl1, g_magFeedTbl2, g_magFeedTbl3, g_magFeedTbl4, g_magFeedTbl5
global g_magFeedTbl6, g_magFeedTbl7, g_magFeedTbl8, g_magFeedTbl9, g_magFeedTbl10   
global g_magFeedTbl11, g_magFeedTbl12, g_magFeedTbl13, g_magFeedTbl14, g_magFeedTbl15
global g_magFeedTbl16 , g_magFeedTbl17, g_magFeedTbl18, g_magFeedTbl19, g_magFeedTbl20
global g_magFeedTbl21, g_magFeedTbl22, g_magFeedTbl23, g_magFeedTbl24, g_magFeedTbl25
global g_magFeedTbl26, g_magFeedTbl27
global g_magArray, g_posArray, g_charCast, g_magTimers

global pauseAfterCycle := false   ; set to true with the MsgBox from Ctrl + E , Ctrl + P defaults it back to false

; Used to decide how many items to purchase in shouldItBuy9(magIdx) 
; Also to decide ImageSearch in FeedMagMacro()
global itemsInventory := []


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


^q:: ; Ctrl + Q - Display itemsInventory 
    displayInventory := ""
    Loop % itemsInventory.Length() {
        displayInventory := displayInventory "`n"
        displayInventory := displayInventory itemsInventory[ A_Index ]
    } 
    MsgBox  itemsInventory, starting at index 1 %displayInventory%
    return


; ----------------------------------------------------------
;    Primary Control Function for User of this script.
;       Author: RoySilverblade, 2018
;
;       Additions by: Beev, 2020
;       Refactored for V1 (current) AutoHotKey
; ----------------------------------------------------------
    

^j::    ; Ctrl + J - Begins the mag feeding macro.
    { 
    ; ------------------------------------------------------
    ;    Perform Edits Here!!!!
    ;   These tables control feed patterns for each mag,
    ;   each table corresponds to one mag you intend to
    ;   level.
    ; ------------------------------------------------------           


    ; CHANGE THE ARRAYS BELOW TO WHAT YOU WANT TO FEED THE MAGS
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

    


    ; SHOULD ADD A MsgBox that verifies how many mags are being fed

    

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


    ; Feed the mag based on the count
    loop % cnt {
        
        Send {F4}        ; Open Mag Menu
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
        
        Send {Enter}        ; select Mag
        
        Send {Enter}        ; select Give Items

        Send {Enter}        ; select Feed Item

        ; reduces the count stored in the itemsInventory array
        DeductInventory()
        Send {F4}         ; exit Mag Menu
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
    Send {Enter}          ; talk to shop

    Send {Enter}          ; select buy
    
    SelectItem( type )      ; select item from store

    Send {Enter}          ; begins item quantity selector
    SelectQuantity( num )   ; select quantity of item 
    
    Send {Enter}          ; brings up buy menu

    Send {Enter}          ; purchases item(s)
    
    ; Push the purchased items into an array to decide when to call shouldItBuy9()
    itemsInventory.Push( type, num )


    Send {Backspace 3} ; Backspace x3, exit out of shop
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


DeductInventory()
    {
    itemsInventory[2] -= 1
    if ( itemsInventory[2] <= 0 )
        {
        itemsInventory.RemoveAt( 1, 2 )
        }
    }

