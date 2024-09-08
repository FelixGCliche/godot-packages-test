@tool
extends PanelContainer

signal failure_next()
signal failure_prevous()
signal request_discover_tests()

signal tree_view_mode_changed(flat :bool)

@onready var _errors := %error_value
@onready var _failures := %failure_value
@onready var _button_errors := %btn_errors
@onready var _button_failures := %btn_failures
@onready var _button_failure_up := %btn_failure_up
@onready var _button_failure_down := %btn_failure_down
@onready var _button_sync := %btn_tree_sync
@onready var _button_view_mode := %btn_tree_mode
@onready var _button_sort_mode := %btn_tree_sort


var total_failed := 0
var total_errors := 0


var icon_mappings := {
	# tree sort modes
	0x100 + GdUnitInspectorTreeConstants.SORT_MODE.UNSORTED : GdUnitUiTools.get_icon("TripleBar"),
	0x100 + GdUnitInspectorTreeConstants.SORT_MODE.NAME_ASCENDING : GdUnitUiTools.get_icon("Sort"),
	0x100 + GdUnitInspectorTreeConstants.SORT_MODE.NAME_DESCENDING : GdUnitUiTools.get_flipped_icon("Sort"),
	0x100 + GdUnitInspectorTreeConstants.SORT_MODE.EXECUTION_TIME : GdUnitUiTools.get_icon("History"),
	# tree view modes
	0x200 + GdUnitInspectorTreeConstants.TREE_VIEW_MODE.TREE : GdUnitUiTools.get_icon("Tree", Color.GHOST_WHITE),
	0x200 + GdUnitInspectorTreeConstants.TREE_VIEW_MODE.FLAT : GdUnitUiTools.get_icon("AnimationTrackGroup", Color.GHOST_WHITE)
}


func _ready() -> void:
	_failures.text = "0"
	_errors.text = "0"
	_button_errors.icon = GdUnitUiTools.get_icon("StatusError")
	_button_failures.icon = GdUnitUiTools.get_icon("StatusError", Color.SKY_BLUE)
	_button_failure_up.icon = GdUnitUiTools.get_icon("ArrowUp")
	_button_failure_down.icon = GdUnitUiTools.get_icon("ArrowDown")
	_button_sync.icon = GdUnitUiTools.get_icon("Loop")
	_set_sort_mode_menu_options()
	_set_view_mode_menu_options()
	GdUnitSignals.instance().gdunit_event.connect(_on_gdunit_event)
	GdUnitSignals.instance().gdunit_settings_changed.connect(_on_settings_changed)
	var command_handler := GdUnitCommandHandler.instance()
	command_handler.gdunit_runner_start.connect(_on_gdunit_runner_start)
	command_handler.gdunit_runner_stop.connect(_on_gdunit_runner_stop)



func _set_sort_mode_menu_options() -> void:
	_button_sort_mode.icon = GdUnitUiTools.get_icon("Sort")
	# construct context sort menu according to the available modes
	var context_menu :PopupMenu = _button_sort_mode.get_popup()
	context_menu.clear()

	if not context_menu.index_pressed.is_connected(_on_sort_mode_changed):
		context_menu.index_pressed.connect(_on_sort_mode_changed)

	var configured_sort_mode := GdUnitSettings.get_inspector_tree_sort_mode()
	for sort_mode: String in GdUnitInspectorTreeConstants.SORT_MODE.keys():
		var enum_value :int =  GdUnitInspectorTreeConstants.SORT_MODE.get(sort_mode)
		var icon :Texture2D = icon_mappings[0x100 + enum_value]
		context_menu.add_icon_check_item(icon, normalise(sort_mode), enum_value)
		context_menu.set_item_checked(enum_value, configured_sort_mode == enum_value)


func _set_view_mode_menu_options() -> void:
	_button_view_mode.icon = GdUnitUiTools.get_icon("Tree", Color.GHOST_WHITE)
	# construct context tree view menu according to the available modes
	var context_menu :PopupMenu = _button_view_mode.get_popup()
	context_menu.clear()

	if not context_menu.index_pressed.is_connected(_on_tree_view_mode_changed):
		context_menu.index_pressed.connect(_on_tree_view_mode_changed)

	var configured_tree_view_mode := GdUnitSettings.get_inspector_tree_view_mode()
	for tree_view_mode: String in GdUnitInspectorTreeConstants.TREE_VIEW_MODE.keys():
		var enum_value :int =  GdUnitInspectorTreeConstants.TREE_VIEW_MODE.get(tree_view_mode)
		var icon :Texture2D = icon_mappings[0x200 + enum_value]
		context_menu.add_icon_check_item(icon, normalise(tree_view_mode), enum_value)
		context_menu.set_item_checked(enum_value, configured_tree_view_mode == enum_value)


func normalise(value: String) -> String:
	var parts := value.to_lower().split("_")
	parts[0] = parts[0].capitalize()
	return " ".join(parts)


func status_changed(errors: int, failed: int) -> void:
	total_failed += failed
	total_errors += errors
	_failures.text = str(total_failed)
	_errors.text = str(total_errors)


func disable_buttons(value :bool) -> void:
	_button_sync.set_disabled(value)
	_button_sort_mode.set_disabled(value)
	_button_view_mode.set_disabled(value)


func _on_gdunit_event(event: GdUnitEvent) -> void:
	match event.type():
		GdUnitEvent.DISCOVER_START:
			disable_buttons(true)

		GdUnitEvent.DISCOVER_END:
			disable_buttons(false)

		GdUnitEvent.INIT:
			total_failed = 0
			total_errors = 0
			status_changed(0, 0)
		GdUnitEvent.TESTCASE_BEFORE:
			pass
		GdUnitEvent.TESTCASE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())
		GdUnitEvent.TESTSUITE_BEFORE:
			pass
		GdUnitEvent.TESTSUITE_AFTER:
			if event.is_error():
				status_changed(event.error_count(), 0)
			else:
				status_changed(0, event.failed_count())


func _on_failure_up_pressed() -> void:
	failure_prevous.emit()


func _on_failure_down_pressed() -> void:
	failure_next.emit()


func _on_tree_sync_pressed() -> void:
	request_discover_tests.emit()


func _on_sort_mode_changed(index: int) -> void:
	var selected_sort_mode :GdUnitInspectorTreeConstants.SORT_MODE = GdUnitInspectorTreeConstants.SORT_MODE.values()[index]
	GdUnitSettings.set_inspector_tree_sort_mode(selected_sort_mode)


func _on_tree_view_mode_changed(index: int) ->void:
	var selected_tree_mode :GdUnitInspectorTreeConstants.TREE_VIEW_MODE = GdUnitInspectorTreeConstants.TREE_VIEW_MODE.values()[index]
	GdUnitSettings.set_inspector_tree_view_mode(selected_tree_mode)


################################################################################
# external signal receiver
################################################################################
func _on_gdunit_runner_start() -> void:
	disable_buttons(true)


func _on_gdunit_runner_stop(_client_id: int) -> void:
	disable_buttons(false)


func _on_settings_changed(property :GdUnitProperty) -> void:
	if property.name() == GdUnitSettings.INSPECTOR_TREE_SORT_MODE:
		_set_sort_mode_menu_options()
	if property.name() == GdUnitSettings.INSPECTOR_TREE_VIEW_MODE:
		_set_view_mode_menu_options()
