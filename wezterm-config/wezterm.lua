local Config = require('config')
local wezterm = require('wezterm')

require('utils.backdrops')
   -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
   :scan_images_dir()
   :random()

require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({
   hide_active_tab_unseen = true,
   unseen_icon = 'numbered_box',
   show_progress = true,
})
require('events.new-tab-button').setup()

-- =====================================================================
-- 🛠️ 终极修复：强制接管系统开窗，完美复用后台常驻会话
-- =====================================================================

wezterm.on('gui-startup', function(cmd)
   local mux = wezterm.mux
   
   -- 1. 尝试寻找后台已有的多路复用窗口
   local tabs = mux.get_all_tabs()
   
   if #tabs > 0 then
      -- 如果后台有现成会话，直接顺着它的脉络把窗口渲染出来，不多开、不新建
      wezterm.log_info("发现后台常驻会话，正在无缝恢复...")
      return
   else
      -- 如果后台由于某种原因是一个完全空壳，强行在 unix 域里生产第一个窗口
      wezterm.log_info("后台为空，正在初始化常驻窗口...")
      local _, _, window = mux.spawn_window {
         domain = { DomainName = 'unix' },
      }
   end
end)

-- 获取并合并你原有的所有模块配置
local final_options = Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options

-- 2. 强制补齐本地多路复用域定义
if not final_options.unix_domains then
   final_options.unix_domains = {}
end

local has_unix = false
for _, dom in ipairs(final_options.unix_domains) do
   if dom.name == 'unix' then
      has_unix = true
      break
   end
end

if not has_unix then
   table.insert(final_options.unix_domains, { name = 'unix' })
end

-- 3. 强制默认域调整为后台 unix 域
final_options.default_domain = 'unix'

return final_options
