local live_command = require("live_command")

describe("Preview", function()
  setup(function()
    live_command.utils = require("live_command.edit_utils")
    live_command.provider = require("live_command.levenshtein_edits_provider")
  end)

  describe("per line", function()
    it("works", function()
      local set_line = mock(function(line_nr, line) end)
      local apply_highlight = mock(function(hl) end)
      local cached_lines = { "Line 1", "Line 2", "Line", "Line" }
      local updated_lines = { "LRne", "LineI 2", "ne 3", "Line" }

      live_command._preview_per_line(
        cached_lines,
        updated_lines,
        { insertion = "I", replacement = "R", deletion = "D" },
        set_line,
        function() end,
        apply_highlight
      )
      assert.stub(set_line).was_called_with(1, "LRne 1")
      assert.stub(set_line).was_called_with(2, "LineI 2")
      assert.stub(set_line).was_called_with(3, "Line 3")
      assert.stub(set_line).was_called_with(4, "Line")

      assert.stub(apply_highlight).was_called_with {
        line = 1,
        start_col = 2,
        end_col = 2,
        hl_group = "R",
      }

      assert.stub(apply_highlight).was_called_with {
        line = 1,
        start_col = 5,
        end_col = 6,
        hl_group = "D",
      }

      assert.stub(apply_highlight).was_called_with {
        line = 2,
        start_col = 5,
        end_col = 5,
        hl_group = "I",
      }

      assert.stub(apply_highlight).was_called_with {
        line = 3,
        start_col = 1,
        end_col = 2,
        hl_group = "D",
      }

      assert.stub(apply_highlight).was_called_with {
        line = 3,
        start_col = 3,
        end_col = 4,
        hl_group = "I",
      }
    end)

    it("deletions are not undone when hl_groups.deletion is nil", function()
      local set_line = mock(function(line_nr, line) end)
      local set_lines = mock(function(lines) end)
      local apply_highlight = mock(function(hl) end)
      local cached_lines = { "Line 1" }
      local updated_lines = { "LRne" }

      live_command._preview_per_line(
        cached_lines,
        updated_lines,
        { insertion = "I", replacement = "R", deletion = nil },
        set_line,
        set_lines,
        apply_highlight
      )
      assert.stub(set_line).was_not_called_with("LRne 1")
      assert.stub(set_line).was_not_called_with("LRne")
      assert.stub(set_lines).was_called_with { "LRne" }

      assert.stub(apply_highlight).was_called_with {
        line = 1,
        start_col = 2,
        end_col = 2,
        hl_group = "R",
      }

      assert.stub(apply_highlight).was_not_called_with {
        line = 1,
        start_col = 5,
        end_col = 6,
        hl_group = "D",
      }
    end)
  end)

  it("across lines", function()
    local updated_lines = {
      "Line 1",
      "Line 2",
    }
  end)
end)
