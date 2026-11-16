/*
 * SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
 *
 * SPDX-License-Identifier: MIT
 */

#include "lvgl/lvgl.h"
#include "ui_screensaver.h"

#if defined(_WIN32)
extern "C" void emu_init_windows_resource_paths(void);
#endif

namespace launcher_ui {
void init();
void deinit();
}

extern "C" void ui_init(void)
{
#if defined(_WIN32)
    emu_init_windows_resource_paths();
#endif
    launcher_ui::init();
    ui_screensaver_init();
    lv_obj_invalidate(lv_scr_act());
    lv_refr_now(NULL);
}

extern "C" void ui_deinit(void)
{
    launcher_ui::deinit();
}
