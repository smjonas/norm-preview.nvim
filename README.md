# live-command.nvim

![live_command_demo](https://user-images.githubusercontent.com/40792180/179546128-ad49096e-7301-4929-9b24-2b08996bdff2.gif)

View the effects of any command on your buffer contents live. Preview macros, the `:norm` command & more!

> :warning: This plugin is still in development and breaking changes may occur without prior announcement.

## Goals and Features
- Provide a very simple interface for creating previewable commands in Neovim
- Smart highlighting based on the Levenshtein distance algorithm (with lots of performance
  improvements and tweaks to get better highlights!)
- View individual insertions, replacements and deletions

## Requirements
Neovim nightly (0.8).

## :rocket: Getting started
Install using your favorite package manager and call the setup function with a table of
commands to create. Here is an example that creates a previewable `:Norm` command:
```lua
use {
  "smjonas/live-command.nvim",
  config = function()
    require("live_command").setup {
      commands = {
        Norm = { cmd = "norm" },
      },
    }
  end,
}
```

## :gear: Usage and Customization
Each command you want to preview requires a name (must be upper-case) and the name of
an existing command that is run on each keypress.

Here is a list of available settings:

| Key         | Type     | Description                                                                                                                                | Optional? |
| ----------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| cmd         | string   | The name of an existing command run in the preview callback.                                                                               | No        |
| args        | string   | Arguments passed to the command. If `nil`, the arguments are supplied from the command-line while the user is typing the command.   | Yes       |

### Example
The following example creates three `:Regx` commands where `x` is the name of a register (`a`, `b` or `c`).
These commands can be used to preview macros.
```lua
local commands = {}
for _, register in ipairs { "a", "b", "c" } do
  commands["Reg" .. register] = { cmd = "norm", args = "@" .. register }
end

require("live_command").setup {
  commands = commands,
}
```
\
All of the following options can be set globally (for all created commands), or per individual command.

To change the default options globally, use the `defaults` table. The defaults are:

```lua
require("live_command").setup {
  defaults = {
    enable_highlighting = true,
    hl_groups = {
      insertion = "DiffAdd",
      deletion = "DiffDelete",
      change = "DiffChanged",
      substitution = "DiffChanged",
    },
    hl_range = { 0, 0, kind = "relative" },
  },
}
```

---

`enable_highlighting: boolean`

Default: `true`

Whether highlights should be shown. If `false`, only text changes are shown.

---

`hl_groups: table<string, string?>`

Default: `{ insertion = "DiffAdd", deletion = "DiffDelete", change = "DiffChanged", substitution = "DiffChanged" }`

A list of highlight groups per edit type (insertion, change, deletion or replacement) used for highlighting buffer changes.
The value can be `nil` in which case no highlights will be shown for that type. If `hl_groups.deletion` is `nil`,
deletion edits will not be undone which is otherwise done to make them visible.

> :bulb: Have a look at the documentation for `substitution_condition` to learn about the difference between `change` and `substitution`.

---

`hl_range: table`

Default: `{ 0, 0, kind = "relative" }`

Determines the line range the command is executed on to calculate the highlights.
By default, if you run a command like `42Norm dsb`, changes to buffer lines outside the
given range (here: `42,42`) will not be previewed for performance reasons.

For certain commands that operate on surrounding lines (such as `dsb`),
it makes sense to increase this range. Use `{ kind = "visible" }` to make the diff
algorithm use all lines that are visible in the current buffer. Tradeoff: this may sometimes be inaccurate
because lines beyond the visible area are affected.

For even more fine-tuned control over the lines there is the `"relative"` kind:
`{ -20, 20, kind = "relative" }` will include the previous / next 20 lines relative to the current
cursor position.

To always use all buffer contents you can use `{ 1, -1, kind = "absolute" }`
(lines are 1-based, negative values are counted from the end of the buffer).
Be aware of potential performance issues when using this option though.

---

`should_substitute: table -> boolean`

Default: `require("live_command").should_substitute`

If a word (defined as a consecutive sequence of non-whitespace characters) is altered by multiple edits,
`live-command` may merge these edits into a single `substitution` edit spanning the entire word.

Whether a substitution is performed depends on the `should_substitute` function. It takes a table with the following keys as a parameter:
`text: string, edits: table, b_start_pos: int, edited_chars_count: table` and must return `true` if the edits should be merged.
The default behavior is as follows:
- If there is only a single edit, create a substitution edit if the edit is in the middle of the word.
- If there are multiple edits, create a substitution edit if at least `word_length / 2`
  characters have been edited.

See [init.lua](https://github.com/smjonas/live-command.nvim/blob/main/lua/live_command/init.lua#L4)
for the default implementation.

---

Like this project? Give it a :star: to show your support!

Also consider checking out my other plugin [inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim),
which is optimized for live-renaming with LSP.
