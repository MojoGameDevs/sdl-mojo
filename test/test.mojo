# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
#
# This program tests if the bindings are correct
#
# Please add more test cases and open issues if anything breaks!
#
import sdl
from sdl import Ptr, InitFlags
from time import monotonic
from math import sqrt

def main():
    print("press WASD to move box")
    alias screen_width = 640
    alias screen_height = 480
    sdl.init(InitFlags.INIT_VIDEO | InitFlags.INIT_AUDIO | InitFlags.INIT_EVENTS | InitFlags.INIT_JOYSTICK | InitFlags.INIT_GAMEPAD)

    var window = Ptr[sdl.Window, MutAnyOrigin]()
    var renderer = Ptr[sdl.Renderer, MutAnyOrigin]()
    sdl.create_window_and_renderer("sdl3 test", screen_width, screen_height, sdl.WindowFlags(0), Ptr(to=window), Ptr(to=renderer))

    var running = True
    var numkeys = Int32()
    var key_state = Span(ptr=sdl.get_keyboard_state(Ptr(to=numkeys)), length=Int(numkeys))
    var rect = sdl.FRect(0, 0, 100, 100)
    var thing = sdl.FRect((screen_width / Float32(2)) - 50, (screen_height / Float32(2)) - 50, 100, 100)
    var ticks = monotonic()
    var delta_time = Float32(0)

    while running:
        var event = sdl.Event(UInt32(0))
        while sdl.poll_event(Ptr(to=event)):
            event_type = sdl.EventType(Int(event[sdl.CommonEvent].type))
            if event_type == sdl.EventType.EVENT_QUIT:
                running = False
            elif event_type == sdl.EventType.EVENT_MOUSE_MOTION:
                var event_ = event[sdl.MouseMotionEvent]
                rect.x = event_.x - 50
                rect.y = event_.y - 50
            elif event_type == sdl.EventType.EVENT_JOYSTICK_AXIS_MOTION:
                print("SDL_EVENT_JOYSTICK_AXIS_MOTION")
            elif event_type == sdl.EventType.EVENT_DISPLAY_CONTENT_SCALE_CHANGED:
                print("SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED")
            elif event_type == sdl.EventType.EVENT_WINDOW_MOVED:
                print("SDL_EVENT_WINDOW_MOVED")
            elif event_type == sdl.EventType.EVENT_AUDIO_DEVICE_ADDED:
                print("SDL_EVENT_AUDIO_DEVICE_ADDED")
            elif event_type == sdl.EventType.EVENT_CLIPBOARD_UPDATE:
                print("SDL_EVENT_CLIPBOARD_UPDATE")
            elif event_type == sdl.EventType.EVENT_DROP_TEXT:
                print("SDL_EVENT_DROP_TEXT")
            elif event_type == sdl.EventType.EVENT_DROP_BEGIN:
                print("SDL_EVENT_DROP_BEGIN")
            elif event_type == sdl.EventType.EVENT_DROP_FILE:
                print("SDL_EVENT_DROP_FILE")
            elif event_type == sdl.EventType.EVENT_GAMEPAD_ADDED:
                print("SDL_EVENT_GAMEPAD_ADDED")


        var acc = sdl.FPoint(0, 0)
        if key_state[sdl.Scancode.SCANCODE_W]:
            acc.y -= 1
        if key_state[sdl.Scancode.SCANCODE_A]:
            acc.x -= 1
        if key_state[sdl.Scancode.SCANCODE_S]:
            acc.y += 1
        if key_state[sdl.Scancode.SCANCODE_D]:
            acc.x += 1
        mag = sqrt(acc.x*acc.x + acc.y*acc.y) or 1
        thing.x += (acc.x / mag) * delta_time
        thing.y += (acc.y / mag) * delta_time

        thing.x = min(max(0, thing.x), screen_width - thing.w)
        thing.y = min(max(0, thing.y), screen_height - thing.h)
        rect.x = min(max(0, rect.x), screen_width - rect.w)
        rect.y = min(max(0, rect.y), screen_height - rect.h)

        sdl.set_render_draw_color(renderer, 4, 8, 16, 100)
        sdl.render_clear(renderer)
        sdl.set_render_draw_color(renderer, 100, 50, 50, 100)
        sdl.render_fill_rect(renderer, Ptr(to=rect))
        sdl.set_render_draw_color(renderer, 50, 100, 50, 100)
        sdl.render_fill_rect(renderer, Ptr(to=thing))
        sdl.render_present(renderer)

        new_ticks = monotonic()
        delta_time = Float32()
        while delta_time < 0.01:
            new_ticks = monotonic()
            delta_time = Float32(new_ticks - ticks) / 1000000.0
        ticks = new_ticks

    sdl.quit()
