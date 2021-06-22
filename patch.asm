;*****************************************************************
;** Project    : Mortal Kombat II MSU                           **
;** Platform   : Sega Genesis                                   **
;** Programmer : http://github.com/b1tsh1fter                   **
;** Version    : 0.1                                            **
;*****************************************************************
; Sourced arcade music here
; https://downloads.khinsider.com/game-soundtracks/album/mortal-kombat-ii-arcade-1993

; CURRENT ISSUES 

; Game over doesn't return to title screen? Hookpoint for patching might be bad or return point
; After 2ND round, if you finish but don't do fatality, music still plays.
; Battle plan screen after fights doesnt play battle plan song currently for some reason

	ORG		 $00000000
    INCBIN 	 "MK2.BIN"			    ; ROM file to patch

;******************************************************
;** INIT MSU DRIVER                                  ** OK
;******************************************************
	ORG      $29ABC
	JSR      INIT_DRIVER
;******************************************************
;** DISABLE Z80 MUSIC                                ** OK
;******************************************************
    ORG      $00005932
    NOP
    NOP
;******************************************************
;** PLAY STARTUP TRACK                               ** OK
;******************************************************
    ORG     $00029B3C
    JMP     PLAY_STARTUP_TRACK
;******************************************************
;** PLAY TITLE TRACK                                 ** OK
;******************************************************
	ORG     $000019D4
	JSR     PLAY_TITLE_TRACK
;******************************************************
;** PLAY CHARACTER SELECT TRACK                      ** OK
;******************************************************
	ORG     $000034A6
	JSR     PLAY_SELECT_TRACK
;******************************************************
;** PLAY BATTLE PLAN TRACK                           ** OK
;******************************************************
	ORG     $00002F9E
	JMP     PLAY_BATTLEPLAN_TRACK
;******************************************************
;** PLAY CONTINUE TRACK                              ** OK
;******************************************************
	ORG     $00017792
	JSR     PLAY_CONTINUE_TRACK
;******************************************************
;** PLAY GAME OVER TRACK                             ** ??
;******************************************************
	ORG     $00001910
	JSR     PLAY_GAMEOVER_TRACK
;******************************************************
;** PLAY STAGE TRACK                                 ** OK
;******************************************************
	ORG     $00000402E
	JMP     PLAY_STAGE_TRACK	
;******************************************************
;** PLAY END ROUND TRACK                             ** OK
;******************************************************
	org     $000064C4
	JMP     PLAY_ENDROUND_TRACK
;******************************************************
;** PLAY FINISH HIM/HER TRACK                        ** ??
;******************************************************
	ORG     $000065FC
	JMP     PLAY_FINISHHIM_TRACK
;******************************************************
;** PLAY FINISHING MOVE TRACK                        ** OK
;******************************************************
	org     $000178F8
	jmp     PLAY_FINISHING_TRACK
;******************************************************
;** PLAY FATALITY TRACK                              ** OK
;******************************************************
	ORG     $00006A6C
	JMP     PLAY_FATALITY_TRACK

;	ORG     $1C20
;	MOVE.W  #$450,D0            ; Adjust the time it takes for "II" timing on title screen

;*******************************************************************************
;** PATCH VARIABLES                                                           **
;*******************************************************************************
				ORG $002FFEC0   ; AT END OF GAME ROM

STARTUP_FLAG EQU $FFFFFF        ; STARTUP TRACK FLAG

MCD_ARG    EQU $A12011	    	; argument (w)
MCD_CMD_CK EQU $A1201F	    	; command clock. increment it for command execution
MCD_STATUS EQU $A12020	    	; 0-ready, 1-init, 2-cmd busy
MCD_CMD    EQU $A12010 	    	; command 
								; 0x11 = Play (playback stopped at end of track). argument = track 1-99 
								; 0x12 = play looped track argument = track 1-99
								; 0x13 = pause playback. argument = vol fading time. 1/75 of sec (75 equal to 1 sec) instant stop if 0 
								; 0x14 = resume playback
								; 0x15 = cdda volume argument= 0-255

STAGE	   EQU $FFAAC1			; (B) WHICH STAGE WE ARE ON		 
								; $0 = DEADPOOL
                                ; $1 = KOMBAT TOMB
                                ; $2 = WASTELAND 
                                ; $3 = TOWER
                                ; $4 = LIVING FOREST
                                ; $5 = ARMORY
                                ; $6 = PIT II (same as wasteland)
                                ; $7 = PORTAL
                                ; $8 = KAHNS ARENA (same as portal)
                                ; $9 = GOROS LAIR ? 
                                ; $A = BLUE PORTAL ? (same as portal)

;*******************************************************************************
;** INIT MSU DRIVER                                                           ** OK
;*******************************************************************************
INIT_DRIVER:
	LEA      MSU_DRIVER,A0      ; POINT TO MSU DRIVER IN A0
	JSR      (A0)               ; JUMP TO IT TO START IT AND COPY IT
	CMP.W    #0,D0              ; DID WE GET 0 ERRORS BACK?
	BNE.S    NO_MCD             ; IF NOT, THEN BRANCH
SET_VOLUME:
	MOVE.B   #0x15,MCD_CMD      ; SET CDDA VOLUME COMMAND
	MOVE.B   #$A0,MCD_ARG       ; SET VOLUME TO 160 OUT OF 255
	ADDQ.B   #2,MCD_CMD_CK      ; RUN THE COMMAND!
SET_VOL_WAIT:
	CMP.B    #0,MCD_STATUS      ; IS MEGACD READY?
	BNE.S    SET_VOL_WAIT       ; KEEP CHECKING UNTIL ITS READY
	JSR      $2A5B2				; DO SEGA LOGO
	JMP      $29AC2				; JUMP BACK
NO_MCD:
    MOVE.L   #$C0000000,$C00004
    MOVE.W   #$000E,$C00000     ; Set border RED
	ILLEGAL                     ; We should probably do something else here rather
	                            ; than die with red screen of death.

;*******************************************************************************
;** PLAY STARTUP TRACK                                                        ** OK
;*******************************************************************************
PLAY_STARTUP_TRACK:
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK LOOPED
	MOVE.B   #1,MCD_ARG         ; PLAY TRACK 1
	ADDQ.B   #1,MCD_CMD_CK
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	MOVE.B   #1,STARTUP_FLAG
	jsr      $2ae9a
	JMP 	 $00029B42			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY TITLE TRACK                                                          ** OK
;*******************************************************************************
PLAY_TITLE_TRACK:
	CMP.B    #1,STARTUP_FLAG
	BEQ.S    PLAY_TITLE_NO
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK 
	MOVE.B   #1,MCD_ARG         ; PLAY TRACK 1
	ADDQ.B   #1,MCD_CMD_CK
PLAY_TITLE_WAIT:
	CMP.B    #0,MCD_STATUS      ; IS MEGACD READY?
	BNE.S    PLAY_TITLE_WAIT    ; KEEP CHECKING UNTIL ITS READY	
PLAY_TITLE_NO:
	MOVE.B   #0,STARTUP_FLAG
	JMP 	 $000019DA			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY CHARACTER SELECT TRACK                                               ** OK
;*******************************************************************************
PLAY_SELECT_TRACK:
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK LOOPED
	MOVE.B   #2,MCD_ARG         ; PLAY TRACK
	ADDQ.B   #2,MCD_CMD_CK
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	JMP 	 $000034AC			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY BATLE PLAN TRACK                                                     ** OK
;*******************************************************************************
PLAY_BATTLEPLAN_TRACK:
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK LOOPED
	MOVE.B   #3,MCD_ARG         ; PLAY TRACK
	ADDQ.B   #2,MCD_CMD_CK
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	jsr      $4aea
	JMP 	 $00002FA4			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY CONTINUE TRACK                                                       ** OK
;*******************************************************************************
PLAY_CONTINUE_TRACK:
	MOVE.B   #0x11,MCD_CMD      ; PLAY TRACK
	MOVE.B   #32,MCD_ARG        ; PLAY TRACK 
	ADDQ.B   #2,MCD_CMD_CK
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	JMP 	 $00017798			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY GAMEOVER TRACK                                                       ** OK
;*******************************************************************************
PLAY_GAMEOVER_TRACK:
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK LOOPED
	MOVE.B   #10,MCD_ARG        ; PLAY TRACK
	ADDQ.B   #2,MCD_CMD_CK
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	JSR      $205c4
	JMP 	 $00001916			; JUMP BACK INTO MAINLINE CODE

;*******************************************************************************
;** PLAY STAGE TRACK                                                          ** OK
;*******************************************************************************
PLAY_STAGE_TRACK:
    CMP.B    #$0,STAGE          ; DEADPOOL?
    BEQ      DEADPOOL
	CMP.B    #$1,STAGE          ; KOMBAT TOMB?
	BEQ      KOMBAT_TOMB
	CMP.B    #$2,STAGE          ; WASTELAND?
	BEQ      WASTELAND	
	CMP.B    #$3,STAGE          ; TOWER?
	BEQ      TOWER
	CMP.B    #$4,STAGE          ; LIVING FOREST?
	BEQ      LIVING_FOREST
	CMP.B    #$5,STAGE          ; ARMORY?
	BEQ      ARMORY
	CMP.B    #$6,STAGE          ; PIT II?
	BEQ      WASTELAND          ; SAME AS WASTELAND
	CMP.B    #$7,STAGE          ; PORTAL?
	BEQ      PORTAL
	CMP.B    #$8,STAGE          ; KAHNS ARENA?
	BEQ      PORTAL             ; SAME AS PORTAL
	CMP.B    #$9,STAGE          ; GOROS LAIR?
	BEQ      GOROS_LAIR
	CMP.B    #$A,STAGE          ; BLUE PORTAL?
	BEQ      PORTAL             ; SAME AS REGULAR PORTAL
	ILLEGAL					    ; DIE!!!
DEADPOOL:
	MOVE.B   #4,MCD_ARG         ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
KOMBAT_TOMB:
	MOVE.B   #7,MCD_ARG         ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
WASTELAND:
	MOVE.B   #10,MCD_ARG        ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
TOWER:
	MOVE.B   #13,MCD_ARG        ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
LIVING_FOREST:
	MOVE.B   #16,MCD_ARG        ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
ARMORY:
	MOVE.B   #19,MCD_ARG        ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
PORTAL:
	MOVE.B   #22,MCD_ARG        ; PLAY TRACK
	BRA      PLAY_STAGE_END     ; EXIT
GOROS_LAIR:
	MOVE.B   #25,MCD_ARG        ; PLAY TRACK
PLAY_STAGE_END:
	MOVE.B   #0x12,MCD_CMD      ; PLAY TRACK LOOPED
	ADDQ.B   #2,MCD_CMD_CK      ; EXECUTE COMMAND
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	MOVE.W   #$1,$ffffef84.w    ; RUN HACKED INSTRUCTION
	JMP      $00004034          ; RETURN

;*******************************************************************************
;** PLAY END ROUND TRACK                                                      ** OK
;*******************************************************************************
PLAY_ENDROUND_TRACK:
    CMP.B    #$0,STAGE          ; DEADPOOL?
    BEQ      DEADPOOL_END_ROUND
	CMP.B    #$1,STAGE          ; KOMBAT TOMB?
	BEQ      KOMBAT_TOMB_END_ROUND
	CMP.B    #$2,STAGE          ; WASTELAND?
	BEQ      WASTELAND_END_ROUND	
	CMP.B    #$3,STAGE          ; TOWER?
	BEQ      TOWER_END_ROUND
	CMP.B    #$4,STAGE          ; LIVING FOREST?
	BEQ      LIVING_FOREST_END_ROUND
	CMP.B    #$5,STAGE          ; ARMORY?
	BEQ      ARMORY_END_ROUND
	CMP.B    #$6,STAGE          ; PIT II?
	BEQ      WASTELAND_END_ROUND; SAME AS WASTELAND
	CMP.B    #$7,STAGE          ; PORTAL?
	BEQ      PORTAL_END_ROUND
	CMP.B    #$8,STAGE          ; KAHNS ARENA?
	BEQ      PORTAL_END_ROUND   ; SAME AS PORTAL
	CMP.B    #$9,STAGE          ; GOROS LAIR?
	BEQ      GOROS_LAIR_END_ROUND
	CMP.B    #$A,STAGE          ; BLUE PORTAL?
	BEQ      PORTAL_END_ROUND   ; SAME AS REGULAR PORTAL
	ILLEGAL					    ; DIE!!!
DEADPOOL_END_ROUND:
	MOVE.B   #5,MCD_ARG         ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
KOMBAT_TOMB_END_ROUND:
	MOVE.B   #8,MCD_ARG         ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
WASTELAND_END_ROUND:
	MOVE.B   #11,MCD_ARG        ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
TOWER_END_ROUND:
	MOVE.B   #14,MCD_ARG        ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
LIVING_FOREST_END_ROUND:
	MOVE.B   #17,MCD_ARG        ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
ARMORY_END_ROUND:
	MOVE.B   #20,MCD_ARG        ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
PORTAL_END_ROUND:
	MOVE.B   #23,MCD_ARG        ; PLAY TRACK
	BRA      ENDROUND_DONE      ; EXIT
GOROS_LAIR_END_ROUND:
	MOVE.B   #26,MCD_ARG        ; PLAY TRACK
ENDROUND_DONE:
	MOVE.B   #0x11,MCD_CMD      ; PLAY TRACK ONCE
	ADDQ.B   #2,MCD_CMD_CK      ; EXECUTE COMMAND
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	JSR      $000006C0          ; RUN HIJACKED INSTRUCTION
	JMP      $000064CA          ; RETURN

;*******************************************************************************
;** PLAY FINISH HIM/HER STAGE TRACK                                           ** OK
;*******************************************************************************
PLAY_FINISHHIM_TRACK:
    CMP.B    #$0,STAGE          ; DEADPOOL?
    BEQ      DEADPOOL_FINISHHIM
	CMP.B    #$1,STAGE          ; KOMBAT TOMB?
	BEQ      KOMBAT_TOMB_FINISHHIM
	CMP.B    #$2,STAGE          ; WASTELAND?
	BEQ      WASTELAND_FINISHHIM	
	CMP.B    #$3,STAGE          ; TOWER?
	BEQ      TOWER_FINISHHIM
	CMP.B    #$4,STAGE          ; LIVING FOREST?
	BEQ      LIVING_FOREST_FINISHHIM
	CMP.B    #$5,STAGE          ; ARMORY?
	BEQ      ARMORY_FINISHHIM
	CMP.B    #$6,STAGE          ; PIT II?
	BEQ      WASTELAND_FINISHHIM; SAME AS WASTELAND
	CMP.B    #$7,STAGE          ; PORTAL?
	BEQ      PORTAL_FINISHHIM
	CMP.B    #$8,STAGE          ; KAHNS ARENA?
	BEQ      PORTAL_FINISHHIM   ; SAME AS PORTAL
	CMP.B    #$9,STAGE          ; GOROS LAIR?
	BEQ      GOROS_LAIR_FINISHHIM
	CMP.B    #$A,STAGE          ; BLUE PORTAL?
	BEQ      PORTAL_FINISHHIM   ; SAME AS REGULAR PORTAL
	ILLEGAL					    ; DIE!!!
DEADPOOL_FINISHHIM:
	MOVE.B   #6,MCD_ARG         ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
KOMBAT_TOMB_FINISHHIM:
	MOVE.B   #9,MCD_ARG         ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
WASTELAND_FINISHHIM:
	MOVE.B   #12,MCD_ARG        ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
TOWER_FINISHHIM:
	MOVE.B   #15,MCD_ARG        ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
LIVING_FOREST_FINISHHIM:
	MOVE.B   #18,MCD_ARG        ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
ARMORY_FINISHHIM:
	MOVE.B   #21,MCD_ARG        ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
PORTAL_FINISHHIM:
	MOVE.B   #24,MCD_ARG        ; PLAY TRACK
	BRA      FINISHHIM_DONE     ; EXIT
GOROS_LAIR_FINISHHIM:
	MOVE.B   #27,MCD_ARG        ; PLAY TRACK
FINISHHIM_DONE:
	MOVE.B   #0x11,MCD_CMD      ; PLAY TRACK ONCE
	ADDQ.B   #2,MCD_CMD_CK      ; EXECUTE COMMAND
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	jsr      $5acc              ; RUN HIJACKED INSTRUCTION
	JMP      $00006602          ; RETURN

;*******************************************************************************
;** PLAY FINISHING TRACK                                                      ** OK
;*******************************************************************************
PLAY_FINISHING_TRACK:
	MOVE.B   #0x11,MCD_CMD      ; PLAY TRACK ONCE
	MOVE.B   #27,MCD_ARG        ; PLAY TRACK
	ADDQ.B   #2,MCD_CMD_CK      ; EXECUTE COMMAND
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11!!!!!!
	; NEEDS A DELAY HERE FOR MUSIC TO START UP     !!
	; FOR TIMING PURPOSES                          !!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11!!!!!!
	JMP      $000178FE          ; RETURN

;*******************************************************************************
;** PLAY FATALITY TRACK                                                       ** OK
;*******************************************************************************
PLAY_FATALITY_TRACK:
	MOVE.B   #0x11,MCD_CMD      ; PLAY TRACK ONCE
	MOVE.B   #28,MCD_ARG        ; PLAY TRACK
	ADDQ.B   #2,MCD_CMD_CK      ; EXECUTE COMMAND
	JSR      MCD_ACKNOWLEDGE    ; ACKNOWLEDGE COMMAND
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11!!!!!!
	; NEEDS A DELAY HERE FOR MUSIC TO START UP     !!
	; FOR TIMING PURPOSES                          !!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11!!!!!!
	MOVE.L   #0x67F0,D7         ; RUN HIJACKED INSTRUCTION
	JMP      $00006A72          ; RETURN

MCD_ACKNOWLEDGE:
	CMP.B    #0,MCD_STATUS      ; IS MEGACD READY?
	BNE.S    MCD_ACKNOWLEDGE    ; KEEP CHECKING UNTIL ITS READY
    RTS

;*****************************************************************
;** MSU DRIVER BINARY                                           **
;*****************************************************************
	EVEN
MSU_DRIVER:
	INCBIN	"MSU-DRV.BIN"		; INCLUDE MSU DRIVER
;*****************************************************************
