local wezterm = require 'wezterm'
local config = wezterm.config_builder()
config.automatically_reload_config = true
config.font_size = 12.0
config.default_prog = { '/bin/zsh', '-l' }
config.use_ime = true
config.window_background_opacity = 0.85
config.colors = {
  background = '#0d1b2a',  
  foreground = '#e3f2fd',  
  cursor_bg = '#64b5f6',   
  cursor_fg = '#0d1b2a',
  
  
  ansi = {
    '#1e3a5f',  
    '#e3f2fd',  
    '#90caf9',  
    '#64b5f6',  
    '#42a5f5',  
    '#bbdefb',  
    '#81d4fa',  
    '#e3f2fd',  
  },
  brights = {
    '#2c5f8d',
    '#ffffff',  
    '#bbdefb',
    '#90caf9',
    '#64b5f6',
    '#e3f2fd',
    '#b3e5fc',
    '#ffffff',
  },
}
config.font = wezterm.font('JetBrainsMono NFM')
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_index + 1 .. ': たぁみなる'
  return title
end)


config.keys = {
  { key = 'R', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  {
    key = 'b',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        overrides.window_background_opacity = 0.5
      else
        overrides.window_background_opacity = 1.0
      end
      window:set_config_overrides(overrides)
    end),
  },
}

-- 4K動画用のGPU加速設定
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
-- Cmd + D で垂直分割（新規タブに近い挙動）を復活させる
config.keys = {
  { key = 'R', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'DefaultDomain' },
}
config.keys = {
  { key = 'R', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  -- Cmd + D で右に分割
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Cmd + Shift + D で下に分割
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- Cmd + W で今いる1枚（ペイン）だけを閉じる（全部飛ばない）
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  -- Cmd + T で新しいタブ
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'DefaultDomain' },
}
config.keys = {
  { key = 'R', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  -- Cmd + Ctrl + F でフルスクリーン切替
  { key = 'f', mods = 'CMD|CTRL', action = wezterm.action.ToggleFullScreen },
  -- Cmd + D で右に分割 / Cmd + Shift + D で下に分割
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- Cmd + W で今いる1枚（ペイン）だけを閉じる
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  -- Cmd + T で新しいタブ
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'DefaultDomain' },
}
-- 設定ファイルを保存した瞬間に自動リロードさせる
config.automatically_reload_config = true
-- Cmd + Shift + R を「再起動」ではなく「設定の強制再読み込み」に割り当てる
table.insert(config.keys, { key = 'r', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration })
-- 画像表示プロトコルを明示的に有効化
--config.enable_kitty_graphics = true
--config.enable_sixel = true

-- もしこれでもダメなら、下の1行をコメントアウト解除して WebGpu から OpenGL に変えてみてください
-- config.front_end = "OpenGL"

return config


