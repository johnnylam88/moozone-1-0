Overview
--------

[MooZone-1.0][project] is a library that provides information about the type of zone in which your character located.


API Methods
-----------

### <a name="getzone"></a>GetZone

Returns the type of zone your character is currenty in.

    zone = lib:GetZone()

#### Returns:

* `zone` - string: the type of zone, one of:
  * `"world"` if in an open world zone,
  * `"arena"` if in an arena,
  * `"battleground"` if in a PVP battleground,
  * `"dungeon"` if in a manually-created dungeon group,
  * `"raid"` if in a manually-created raid group,
  * `"scenario"` if in a scenario,
  * `"lfg_dungeon"` if in a Dungeon Finder group,
  * `"lfg_raid"` if in a Raid Finder group.

### GetLocalizedZone

Returns the localized zone name.

    localizedZone = lib:GetLocalizedZone(zone)

#### Arguments:

* `zone` - string: the type of zone, see [GetZone](#getzone)

#### Returns:

* `localizedZone` - string: the localized zone name

### ZoneIterator

Returns an iterator that gives key-value pairs of zone and localized zone name.

    for zone, localizedZone in lib:ZoneIterator() do
        ...
    end

### RegisterCallback

Registers a function to handle the specified callback.

    lib.RegisterCallback(handler, callback, method, arg)

#### Arguments:

* `handler` - table/string: your addon object or another table containing a function at `handler[method]`, or a string identifying your addon
* `callback` - string: the name of the callback to be registered
* `method` - string/function/nil: a key into the `handler` table, or a function to be called, or `nil` if `handler` is a table and a function exists at `handler[callback]`
* `arg` - a value to be passed as the first argument to the callback function specified by `method`

#### Notes:

* If `handler` is a table, `method` is a string, and `handler[method]` is a function, then that function will be called with `handler` as its first argument, followed by the callback name and the callback-specific arguments.
* If `handler` is a table, `method` is nil, and `handler[callback]` is a function, then that function will be called with `handler` as its first argument, followed by the callback name and the callback-specific arguments.
* If `handler` is a string and `method` is a function, then that function will be called with the callback name as its first argument, followed by the callback-specific arguments.
* If `arg` is non-nil, then it will be passed to the specified function. If `handler` is a table, then `arg` will be passed as the second argument, pushing the callback name to the third position. Otherwise, `arg` will be passed as the first argument.

### UnregisterCallback

Unregisters a specified callback.

    lib.UnregisterCallback(handler, callback)

#### Arguments:

* `handler` - table/string: your addon object or a string identifying your addon
* `callback` - string: the name of the callback to be unregistered


Callbacks
---------

__MooZone-1.0__ provides the following callbacks to notify interested addons when the zone type has changed.

### MooZone_ZoneChanged

Fires when the zone type in which the character is located changes.

#### Arguments:

* `oldZone` - string: the previous zone type, see [GetZone](#getzone)
* `newZone` - string: the current zone type, see [GetZone](#getzone)


License
-------
__MooZone-1.0__ is released under the 2-clause BSD license.


Feedback
--------

+ [Report a bug or suggest a feature][project-issue-tracker].

  [project]: https://www.github.com/ultijlam/moozone-1-0
  [project-issue-tracker]: https://github.com/ultijlam/moozone-1-0/issues