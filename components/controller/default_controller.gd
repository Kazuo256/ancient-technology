
extends Node

const GAME_RESOLUTION = Vector2(1280, 720)

var enabled = true
var actions = {}

func _init():
  if self extends Control:
    set_process_input(true)
  else:
    set_process_unhandled_input(true)
  build_action_dict()

func enable():
  #print("enable ", get_path())
  enabled = true

func disable():
  #print("disable ", get_path())
  enabled = false

func _input_event(event):
  if not event.is_pressed():
    return

  if event.type == InputEvent.KEY or event.type == InputEvent.MOUSE_BUTTON:
    consume_input_key(event)
    
  

func _input(event):
  _input_event(event)

func _unhandled_input(event):
  _input_event(event)

func get_event_name(action):
  return "event_" + action.replace("ui_", "").replace("debug_", "")

func build_action_dict():
  var index = 1
  var action = InputMap.get_action_from_id(index)

  while action != "":
    index += 1
    action = InputMap.get_action_from_id(index)
    var method_name = get_event_name(action)
    #printt("action=", action, "method=", method_name)
    if self.has_method(method_name):
      #printt("method=", method_name, " found")
      actions[action] = funcref(self, method_name)
      if self.get_tree() != null:
        self.get_tree().set_input_as_handled()
    #else:
    #  printt("method=", method_name, " not found")
  #printt("actions=", actions)

func consume_input_key(event):
  if not enabled:
    return

  for action in actions.keys():
    if event.is_action_pressed(action):
      #print("calling method ", get_event_name(action), " action ", action)
      actions[action].call_func()
      return

func event_cancel():
  get_tree().quit()

func event_toggle_fullscreen():
  self.get_tree().set_input_as_handled()
  if OS.is_window_fullscreen():
    OS.set_window_fullscreen(false)
    get_viewport().set_size_override_stretch(false)
    get_viewport().set_size_override(true, GAME_RESOLUTION, Vector2(0,0))
  else:
    var screen_size = OS.get_screen_size()
    var ratio = screen_size/GAME_RESOLUTION
    ratio = ratio.floor()
    var scaling = min(ratio.x, ratio.y)
    var margin = screen_size/scaling - GAME_RESOLUTION
    OS.set_window_fullscreen(true)
    get_viewport().set_size_override_stretch(true)
    get_viewport().set_size_override(true, GAME_RESOLUTION, margin/2.0)
