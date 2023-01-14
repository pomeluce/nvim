local G = require('G')
local packer_bootstrap = false
local install_path = G.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local compiled_path = G.fn.stdpath('config')..'/plugin/packer_compiled.lua'
if G.fn.empty(G.fn.glob(install_path)) > 0 then
    print('Installing packer.nvim...')
    G.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    G.fn.system({'rm', '-rf', compiled_path})
    G.cmd [[packadd packer.nvim]]
    packer_bootstrap = true
end

-- 所有插件配置分 config 和 setup 部分
-- config 发生在插件载入前 一般为 let g:xxx = xxx 或者 hi xxx xxx 或者 map x xxx 之类的 配置
-- setup  发生在插件载入后 一般为 require('xxx').setup() 之类的配置
require('packer').startup({
	function(use)
		-- packer 管理自己的版本
		use { 'wbthomason/packer.nvim' }

		-- 启动时间分析
        	use { "dstein64/vim-startuptime", cmd = "StartupTime" }

		-- 中文help doc
        	use { 'yianwillis/vimcdoc', event = 'VimEnter' }

		-- vv 快速选中内容插件
        	require('pack/vim-expand-region').config()
        	use { 'terryma/vim-expand-region', config = "require('pack/vim-expand-region').setup()", event = 'CursorHold' }
	end
})

if packer_bootstrap then
	require('packer').sync()
end
