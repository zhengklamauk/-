.386
.model flat, stdcall
option casemap:none

include     windows.inc
include     user32.inc
includelib  user32.lib
include     kernel32.inc
includelib  kernel32.lib

IDD_DLG1 equ 1000
IDC_BTN1 equ 1002
IDC_BTN2 equ 1003
IDC_BTN3 equ 1004
IDC_BTN4 equ 1005

.data?
hInstance   dword ?
hDlgMain    dword ?
Array       byte 800 dup(?)

.data
dwMenuID    dword 209h, 20Ah, 20Bh
szCaption   byte "É¨À×", 0
szErr       byte "ÕÒ²»µ½É¨À×ÓÎÏ·", 0
BaseAddr    dword 01005361h
xPos        word 19
yPos        word 61

.code
main proc
    push 0
    call GetModuleHandle
    cmp eax, 0
    je __RET
    mov hInstance, eax

    push 0
    push offset _DlgMainCallBack
    push 0
    push IDD_DLG1
    push hInstance
    call DialogBoxParam

__RET:
    push 0
    call ExitProcess
main endp


_DlgMainCallBack proc hWnd, uMsg, wParam, lParam
    mov eax, uMsg

    .if eax==WM_COMMAND
        mov eax, wParam
        .if ax==IDC_BTN1
            push 0
            call _ChangeLevel

        .elseif ax==IDC_BTN2
            push 1
            call _ChangeLevel

        .elseif ax==IDC_BTN3
            push 2
            call _ChangeLevel

        .elseif ax==IDC_BTN4
            call _Clear
        .endif

    .elseif eax==WM_INITDIALOG
        mov eax, hWnd
        mov hDlgMain, eax

    .elseif eax==WM_CLOSE
        push 0
        push hWnd
        call EndDialog

    .else
        mov eax, FALSE
        ret
    .endif

    mov eax, TRUE
    ret
_DlgMainCallBack endp


_ChangeLevel proc
;[ebp+8h]       Level
;[ebp-4h]       hWinmine
    push ebp
    mov ebp, esp
    sub esp, 10h

    push offset szCaption
    push 0
    call FindWindow
    cmp eax, 0
    je __ERR
    mov dword ptr ss:[ebp-4h], eax

    push 0
    mov eax, dword ptr ss:[ebp+8h]
    shl eax, 2
    push [dwMenuID+eax]
    push 111h
    push dword ptr ss:[ebp-4h]
    call PostMessage
    jmp __RET

__ERR:
    push MB_OK
    push 0
    push offset szErr
    push 0
    call MessageBox

__RET:
    mov esp, ebp
    pop ebp
    ret
_ChangeLevel endp


_Clear proc
;[ebp-4h]       hWinmine
;[ebp-8h]       ProcessID
;[ebp-0ch]      hProcess
;[ebp-10h]      RowIndex
    push ebp
    mov ebp, esp
    sub esp, 20h

    push IDC_BTN4
    push hDlgMain
    call GetDlgItem
    push FALSE
    push eax
    call EnableWindow

    push offset szCaption
    push 0
    call FindWindow
    cmp eax, 0
    je __ERR
    mov dword ptr ss:[ebp-4h], eax

    push 001B0054h
    push 1
    push WM_LBUTTONDOWN
    push dword ptr ss:[ebp-4h]
    call PostMessage
    push 001B0054h
    push 0
    push WM_LBUTTONUP
    push dword ptr ss:[ebp-4h]
    call PostMessage

    push 003D0013h
    push 1
    push WM_LBUTTONDOWN
    push dword ptr ss:[ebp-4h]
    call PostMessage
    push 003D0013h
    push 0
    push WM_LBUTTONUP
    push dword ptr ss:[ebp-4h]
    call PostMessage
    mov ax, xPos
    add ax, 16
    mov xPos, ax

    lea eax, dword ptr ss:[ebp-8h]
    push eax
    push dword ptr ss:[ebp-4h]
    call GetWindowThreadProcessId
    cmp eax, 0
    je __ERR

    push dword ptr ss:[ebp-8h]
    push 0
    push PROCESS_ALL_ACCESS
    call OpenProcess
    cmp eax, 0
    je __ERR
    mov dword ptr ss:[ebp-0ch], eax

    push 0
    push 800
    lea eax, Array
    push eax
    push BaseAddr
    push dword ptr ss:[ebp-0ch]
    call ReadProcessMemory
    cmp eax, 0
    je __CH

    xor ebx, ebx
    mov edi, 1
    mov dword ptr ss:[ebp-10h], ebx
__L1:
    push 50
    call Sleep
    mov al, Array[ebx+edi*TYPE Array]
    cmp al, 10h
    je __NLOW
    cmp al, 8Fh
    je __NCOLUMN
    ;
    mov ax, yPos
    shl eax, 16
    or ax, xPos
    push eax
    push 1
    push WM_LBUTTONDOWN
    push dword ptr ss:[ebp-4h]
    call PostMessage
    mov ax, yPos
    shl eax, 16
    or ax, xPos
    push eax
    push 0
    push WM_LBUTTONUP
    push dword ptr ss:[ebp-4h]
    call PostMessage

__NCOLUMN:
    mov ax, xPos
    add ax, 16
    mov xPos, ax
    inc edi
    jmp __L1

__NLOW:
    mov ax, yPos
    add ax, 16
    mov yPos, ax
    mov ax, 19
    mov xPos, ax
    xor edi, edi
    inc dword ptr ss:[ebp-10h]
    mov eax, 32
    mul dword ptr ss:[ebp-10h]
    mov ebx, eax
    mov eax, dword ptr Array[ebx+edi*TYPE Array]
    cmp eax, 10101010h
    jne __L1
    push dword ptr ss:[ebp-0ch]
    call CloseHandle
    jmp __RET

__CH:
    push dword ptr ss:[ebp-0ch]
    call CloseHandle

__ERR:
    push MB_OK
    push 0
    push offset szErr
    push 0
    call MessageBox

__RET:
    mov ax, 19
    mov xPos, ax
    mov ax, 61
    mov yPos, ax

    push IDC_BTN4
    push hDlgMain
    call GetDlgItem
    push TRUE
    push eax
    call EnableWindow

    mov esp, ebp
    pop ebp
    ret
_Clear endp
end main