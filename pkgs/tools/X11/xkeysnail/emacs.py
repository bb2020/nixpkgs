# -*- coding: utf-8 -*-
import re
from xkeysnail.transform import *

aa = False
def aa_svar():
    def _aa_svar():
        global aa; transform._mark_set = False
        aa = True
    return _aa_svar
def aa_uvar():
    def _aa_uvar():
        global aa; transform._mark_set = False
        aa = False
    return _aa_uvar
def aa_ivar():
    def _aa_ivar():
        global aa; transform._mark_set = False
        if aa: aa = False; return K("esc")
        return K("enter")
    return _aa_ivar
def aa_flip():
    def _aa_flip():
        transform._mark_set = not transform._mark_set;
    return _aa_flip

define_keymap(re.compile("Google-chrome|Chromium-browser|firefox"), {
    K("C-b"): with_mark(K("left")),
    K("C-f"): with_mark(K("right")),
    K("C-p"): with_mark(K("up")),
    K("C-n"): with_mark(K("down")),
    K("M-b"): with_mark(K("C-left")),
    K("M-f"): with_mark(K("C-right")),
    K("C-a"): with_mark(K("home")),
    K("C-e"): with_mark(K("end")),

    K("C-w"): [K("C-x"), set_mark(False)],
    K("M-w"): [K("C-c"), K("right"), set_mark(False)],
    K("C-y"): [K("C-v"), set_mark(False)],
    K("C-k"): [K("Shift-end"), K("C-x"), set_mark(False)],
    K("C-d"): [K("delete"), set_mark(False)],
    K("M-d"): [K("C-delete"), set_mark(False)],
    K("M-backspace"): [K("C-backspace"), set_mark(False)],
    K("C-slash"): [K("C-z"), set_mark(False)],

    K("C-M-space"): with_or_set_mark(K("C-right")),
    # K("C-space"): set_mark(True),
    # K("C-s"): K("F3"),
    # K("C-r"): K("Shift-F3"),
    # K("C-g"): [K("esc"), set_mark(False)]

    K("C-space"): aa_flip(),
    K("C-s"): [K("F3"), aa_svar()],
    K("C-r"): [K("Shift-F3"), aa_svar()],
    K("C-g"): [K("esc"), aa_uvar()],
    K("enter"): aa_ivar()
})
