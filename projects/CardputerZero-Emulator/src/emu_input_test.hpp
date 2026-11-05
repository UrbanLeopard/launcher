/* SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
 * SPDX-License-Identifier: MIT */
#pragma once

// Compiled only when BUILD_TESTING is enabled. Tests report state and fail via
// the process exit status; diagnostic keyboard logs are not part of the contract.
class EmulatorInputTest {
public:
    EmulatorInputTest(SDL_Window *window, SDL_Renderer *renderer)
        : window_(window), renderer_(renderer),
          click_frame_(emu_test_frame("EMU_TEST_CLICK_FRAME"))
    {
        if (click_frame_) {
            click_event_ = SDL_RegisterEvents(1);
            failed_ = click_event_ == static_cast<uint32_t>(-1);
        }
    }

    bool observe_event(const SDL_Event &event)
    {
        if (!click_frame_ || event.type != click_event_) return false;
        click_pending_ = true;
        return true;
    }

    void observe_click(int side)
    {
        if (!click_pending_) return;
        click_pending_ = false;
        click_done_ = side == 3 && g_kbd_handler;
        failed_ = failed_ || !click_done_;
        printf("[EMU_TEST] click=%s\n", click_done_ ? "pass" : "fail");
    }

    void advance(unsigned frame)
    {
        if (failed_) return;
        if (click_frame_ && !click_queued_ && frame >= click_frame_) {
            SDL_Event marker = {};
            marker.type = click_event_;
            SDL_Event down = {};
            down.type = SDL_MOUSEBUTTONDOWN;
            down.button.windowID = SDL_GetWindowID(window_);
            down.button.button = SDL_BUTTON_LEFT;
            down.button.state = SDL_PRESSED;
            const auto &next = g_side_keys[3];
            SDL_RenderLogicalToWindow(renderer_, next.x + next.w / 2.0f,
                next.y + next.h / 2.0f, &down.button.x, &down.button.y);
            SDL_Event up = down;
            up.type = SDL_MOUSEBUTTONUP;
            up.button.state = SDL_RELEASED;
            failed_ = SDL_PushEvent(&marker) != 1 ||
                      SDL_PushEvent(&down) != 1 || SDL_PushEvent(&up) != 1;
            click_queued_ = true;
        }
    }

    bool finish()
    {
        failed_ = failed_ || (click_frame_ && !click_done_);
        if (failed_) fprintf(stderr, "[EMU_TEST] result=fail\n");
        return !failed_;
    }

private:
    SDL_Window *window_;
    SDL_Renderer *renderer_;
    unsigned click_frame_;
    uint32_t click_event_ = 0;
    bool click_pending_ = false, click_queued_ = false, click_done_ = false;
    bool failed_ = false;
};
